#!/usr/bin/env bash
#
# gen_string_schema.sh — emit an all-STRING BigQuery schema JSON from a CSV header.
#
# PLUTO releases drift in their columns year to year, so each yearly CSV gets its
# own schema. Typing everything as STRING keeps the load robust (messy NYC values
# never break it); casting happens later, in dbt staging.
#
# Usage:
#   build/gen_string_schema.sh gs://bucket/pluto_25v3.csv > build/schemas/pluto_25v3.json
#   build/gen_string_schema.sh local/file.csv

set -euo pipefail
src="${1:?usage: gen_string_schema.sh <csv-path-or-gs-uri>}"

if [[ "$src" == gs://* ]]; then
  # Ranged read: `gcloud storage cat` without -r streams the whole object, which
  # takes minutes on the multi-GB DOB exports even though we only want line 1.
  # Require a newline in the chunk rather than piping to `head -1`, which would
  # silently return a truncated header if one ever exceeded the range.
  chunk="$(gcloud storage cat -r 0-65535 "$src" 2>/dev/null || true)"
  [[ "$chunk" == *$'\n'* ]] || { echo "error: no header line in first 64KiB of $src" >&2; exit 1; }
  header="${chunk%%$'\n'*}"
else
  header="$(head -1 "$src")"
fi

[[ -n "$header" ]] || { echo "error: could not read header from $src" >&2; exit 1; }

python3 - "$header" <<'PY'
import sys, json, re


def sanitize(name):
    """Turn a human-readable CSV header into a legal BigQuery column name.

    BigQuery column names must match ^[A-Za-z_][A-Za-z0-9_]*$. PLUTO headers
    already do, so this is a no-op there. DOB's exports do not: 47 of the 60
    headers in the permit dataset are illegal (`Bin #`, `Permittee's Phone #`,
    `Superintendent First & Last Name`, ...). Without sanitizing, this script
    cannot generate a usable schema for those datasets at all — which is why
    build/schemas/permit_issuance.json was hand-written, and how it drifted out
    of alignment with the real CSV.

    The specific rules below are not arbitrary: they are the rules that
    reproduce the column names the dbt models already reference, so
    regenerating a schema does not silently rename columns out from under
    staging. Each is load-bearing for at least one real header.
    """
    s = name.strip()

    # Possessives collapse rather than leaving a stray "s": DOB writes
    # "Permittee's First Name", and stg_permits reads Permittee_First_Name.
    # Both ASCII and curly apostrophes appear in the same header row —
    # "Owner's House #" but "Owner’s House City".
    s = re.sub(r"[’']s\b", "", s)
    s = s.replace("’", "").replace("'", "")

    # "#" means "number" in these headers and is dropped by the generic
    # non-alphanumeric rule below, which would collide "Job #" with "Job".
    # Spelling it out keeps Job_No / Bin_No / Permit_Sequence_No distinct.
    s = s.replace("#", "No")

    # "&" is pure connective in "Superintendent First & Last Name"; dropping it
    # gives Superintendent_First_Last_Name rather than a doubled separator.
    s = s.replace("&", "")

    # Everything else non-alphanumeric (spaces, ".", "-", "/") becomes "_",
    # then collapse runs and trim edges so "Job doc. #" -> Job_doc_No rather
    # than Job_doc__No.
    s = re.sub(r"[^0-9A-Za-z]+", "_", s)
    s = re.sub(r"_+", "_", s).strip("_")

    # A name may not start with a digit; prefix rather than drop, so a header
    # like "2020 Census Tract" stays distinguishable.
    if not s or not re.match(r"^[A-Za-z_]", s):
        s = "_" + s
    return s


header = sys.argv[1].rstrip("\r\n")
cols = [sanitize(c) for c in header.split(",")]

# A duplicate name would make the load fail with a confusing error far from the
# cause, and a silently deduped one would shift every later column — exactly the
# failure mode that corrupted the hand-written permit schema. Fail loudly here.
dupes = sorted({c for c in cols if cols.count(c) > 1})
if dupes:
    sys.exit(f"error: sanitized header has duplicate column names: {dupes}")

print(json.dumps([{"name": c, "type": "STRING"} for c in cols], indent=2))
PY
