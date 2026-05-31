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
  header="$(gcloud storage cat "$src" 2>/dev/null | head -1 || true)"
else
  header="$(head -1 "$src")"
fi

[[ -n "$header" ]] || { echo "error: could not read header from $src" >&2; exit 1; }

python3 - "$header" <<'PY'
import sys, json
header = sys.argv[1].rstrip("\r\n")
cols = [c.strip() for c in header.split(",")]
print(json.dumps([{"name": c, "type": "STRING"} for c in cols], indent=2))
PY
