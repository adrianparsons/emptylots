#!/usr/bin/env bash
#
# upload_pluto_to_gcs.sh — upload the locally-vendored PLUTO release CSVs to the
# raw bucket so bq.load.pluto can load them.
#
# get_historical_pluto.sh (make vendor.pluto) downloads + unzips each release
# into historical/<slug>/. This step copies each release's CSV up to
# ${RAW_BUCKET}/pluto/<slug>.csv — the layout load_pluto_to_bigquery.sh reads.
#
# Reads the same build/sources.tsv catalog as the fetch step, so it only uploads
# releases that are actually cataloged.
#
#   make vendor.pluto.upload

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="${here}/sources.tsv"
root="$(cd "${here}/.." && pwd)"

bucket="${RAW_BUCKET:?set RAW_BUCKET (e.g. run via 'make vendor.pluto.upload')}"
bucket="${bucket%/}"

[[ -f "$manifest" ]] || { echo "error: manifest not found: $manifest" >&2; exit 1; }

while IFS=$'\t' read -r type slug url filename publisher dataset_id || [[ -n "$type" ]]; do
  # Skip blank lines, comments (#...), and the header row.
  case "$type" in ''|'#'*|type) continue ;; esac
  [[ "$type" == "pluto" ]] || continue

  csv="${root}/historical/${slug}/${slug}.csv"
  [[ -f "$csv" ]] || { echo "error: missing ${csv} — run 'make vendor.pluto' first" >&2; exit 1; }

  dest="${bucket}/pluto/${slug}.csv"
  echo ">> uploading ${slug} -> ${dest}"
  gcloud storage cp "$csv" "$dest"
done < "$manifest"

echo "All PLUTO uploads complete."
