#!/usr/bin/env bash
#
# upload_geometry_to_gcs.sh — upload the MapPLUTO lot-geometry GeoJSONL to the
# raw bucket so bq.load.geometry can load it.
#
# MapPLUTO geometry isn't a cataloged download (it's derived from the DCP
# MapPLUTO release, not a single open-data CSV), so this takes the local file
# as an argument and copies it to ${RAW_BUCKET}/pluto/MapPLUTO.geojsonl — the
# path load_geojson_to_bigquery.sh reads.
#
#   make vendor.geometry.upload FILE=path/to/MapPLUTO.geojsonl
#
# FILE defaults to MapPLUTO.geojsonl in the repo root.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bucket="${RAW_BUCKET:?set RAW_BUCKET (e.g. run via 'make vendor.geometry.upload')}"
bucket="${bucket%/}"
file="${FILE:-${root}/MapPLUTO.geojsonl}"

[[ -f "$file" ]] || { echo "error: missing ${file} — pass FILE=path/to/MapPLUTO.geojsonl" >&2; exit 1; }

dest="${bucket}/pluto/MapPLUTO.geojsonl"
echo ">> uploading ${file} -> ${dest}"
gcloud storage cp "$file" "$dest"

echo "Geometry upload complete."
