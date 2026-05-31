#!/usr/bin/env bash
#
# upload_geometry_to_gcs.sh — upload a pre-converted MapPLUTO GeoJSONL to the
# raw bucket so bq.load.geometry can load it.
#
# This is an escape hatch for when you already have the GeoJSONL locally.
# The normal path is `make vendor.geometry` (get_mappluto_geometry.sh), which
# downloads the shapefile from sources.tsv and converts it in one step.
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
