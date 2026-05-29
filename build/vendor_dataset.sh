#!/usr/bin/env bash
#
# vendor_dataset.sh — fetch a City of New York dataset and snapshot it to GCS.
#
# The one reproducible step for bringing raw data into the project: download the
# source file, upload it to a dated path in the raw bucket, and print a block to
# paste into dbt/models/staging/sources.yml. dbt does the rest — the external
# table (`make dbt.stage_external`) points at the path this writes.
#
# Usage:
#   build/vendor_dataset.sh \
#     --slug dob_permit_issuance \
#     --url  'https://data.cityofnewyork.us/api/views/ipu4-2q9a/rows.csv?accessType=DOWNLOAD' \
#     --publisher 'NYC Department of Buildings' \
#     [--dataset-id ipu4-2q9a]            # NYC Open Data id, for the docs \
#     [--version 2026-05-29]              # defaults to today (UTC) \
#     [--filename permit_issuance.csv]    # defaults to <slug>.csv \
#     [--bucket gs://nyc-pluto-historical] \
#     [--force]                           # allow overwriting an existing version

set -euo pipefail

bucket="gs://nyc-pluto-historical"
version="$(date -u +%Y-%m-%d)"
slug="" url="" publisher="" dataset_id="" filename="" force=""

die() { echo "error: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug)       slug="$2"; shift 2 ;;
    --url)        url="$2"; shift 2 ;;
    --publisher)  publisher="$2"; shift 2 ;;
    --dataset-id) dataset_id="$2"; shift 2 ;;
    --version)    version="$2"; shift 2 ;;
    --filename)   filename="$2"; shift 2 ;;
    --bucket)     bucket="${2%/}"; shift 2 ;;
    --force)      force=1; shift ;;
    -h|--help)    sed -n '2,20p' "$0"; exit 0 ;;
    *)            die "unknown argument: $1" ;;
  esac
done

[[ -n "$slug" ]]      || die "--slug is required"
[[ -n "$url" ]]       || die "--url is required"
[[ -n "$publisher" ]] || die "--publisher is required"
[[ -n "$filename" ]]  || filename="${slug}.csv"

dest="${bucket}/raw/${slug}/${version}/${filename}"

# Dated paths are meant to be stable snapshots; don't clobber one by accident.
if [[ -z "$force" ]] && gcloud storage ls "$dest" >/dev/null 2>&1; then
  die "$dest already exists — bump --version, or pass --force to overwrite."
fi

tmpdir="$(mktemp -d)"; trap 'rm -rf "$tmpdir"' EXIT
local_file="${tmpdir}/${filename}"

echo ">> downloading $url" >&2
curl --fail --location --progress-bar "$url" -o "$local_file"

# Cheap extras that make the source self-describing in dbt docs.
sha256="$(shasum -a 256 "$local_file" | awk '{print $1}')"
row_count="$(($(wc -l < "$local_file" | tr -d ' ') - 1))"
retrieved_at="$(date -u +%Y-%m-%d)"

echo ">> uploading to $dest" >&2
gcloud storage cp "$local_file" "$dest"

cat <<EOF

────────────────────────────────────────────────────────────────────────────
Vendored ${slug} @ ${version}
  snapshot:  ${dest}
  rows:      ${row_count}
  sha256:    ${sha256}

Next:
  1. In dbt/models/staging/sources.yml, set this table's meta.version: "${version}"
  2. In the Makefile, point its *_CSV variable at:
        ${dest}
  3. make bq.load.<dataset>
────────────────────────────────────────────────────────────────────────────
EOF
