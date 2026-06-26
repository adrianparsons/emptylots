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

# Collect the cataloged CSV paths, then upload them all in one batched cp below.
csvs=()
while IFS=$'\t' read -r type slug url filename publisher dataset_id || [[ -n "$type" ]]; do
  # Skip blank lines, comments (#...), and the header row.
  case "$type" in ''|'#'*|type) continue ;; esac
  [[ "$type" == "pluto" ]] || continue

  csv="${root}/historical/${slug}/${slug}.csv"
  [[ -f "$csv" ]] || { echo "error: missing ${csv} — run 'make vendor.pluto' first" >&2; exit 1; }
  csvs+=("$csv")
done < "$manifest"

[[ ${#csvs[@]} -gt 0 ]] || { echo "no cataloged PLUTO CSVs found"; exit 0; }

# One batched upload of all cataloged CSVs into the flat pluto/ prefix (each
# lands as pluto/<slug>.csv — basename preserved). --no-clobber skips any
# release already in the bucket: PLUTO releases are version-pinned and immutable
# (a new release is a new slug), so a run after adding one release uploads just
# that release instead of re-pushing every CSV. gcloud parallelizes across the
# files and slices each large file via composite upload.
echo ">> uploading ${#csvs[@]} CSV(s) to ${bucket}/pluto/ (skipping any already present)"
gcloud storage cp --no-clobber "${csvs[@]}" "${bucket}/pluto/"

echo "All PLUTO uploads complete."
