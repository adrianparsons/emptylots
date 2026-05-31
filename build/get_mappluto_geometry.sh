#!/usr/bin/env bash
#
# get_mappluto_geometry.sh — download a MapPLUTO shapefile zip, convert it to
# GeoJSONL, and upload it to the raw bucket.
#
# Converts a newline-delimited GeoJSON file (one Feature per line, WGS-84, BBL
# property only) and uploads to ${RAW_BUCKET}/${DEST}.
#
# Required env vars:
#   RAW_BUCKET   — GCS bucket (e.g. gs://nyc-lots-raw-data)
#   URL          — URL of the shapefile zip to download
#   DEST         — bucket-relative output path (e.g. pluto/MapPLUTO.geojsonl)
#
# Optional:
#   CONTAINER_CMD — container runtime (default: docker)
#
#   make vendor.geometry

set -euo pipefail

bucket="${RAW_BUCKET:?set RAW_BUCKET (e.g. run via 'make vendor.geometry')}"
bucket="${bucket%/}"
url="${URL:?set URL (e.g. run via 'make vendor.geometry')}"
dest_path="${DEST:?set DEST (e.g. run via 'make vendor.geometry')}"
container_cmd="${CONTAINER_CMD:-docker}"

command -v "$container_cmd" >/dev/null 2>&1 \
  || { echo "error: ${container_cmd} not found — install Docker Desktop or set CONTAINER_CMD" >&2; exit 1; }

tmpdir="$(mktemp -d)"; trap 'rm -rf "$tmpdir"' EXIT

zip="${tmpdir}/$(basename "$url")"
echo ">> downloading ${url}"
curl --fail --location --progress-bar "$url" -o "$zip"

echo ">> unzipping"
unzip -q "$zip" -d "${tmpdir}/extracted"

shp="$(find "${tmpdir}/extracted" -name "*.shp" | head -1)"
[[ -n "$shp" ]] || { echo "error: no .shp file found in zip" >&2; exit 1; }
echo ">> found shapefile: $(basename "$shp")"

geojsonl_name="$(basename "$dest_path")"
geojsonl="${tmpdir}/${geojsonl_name}"
shp_rel="${shp#"${tmpdir}/"}"   # path relative to tmpdir, e.g. extracted/MapPLUTO.shp

echo ">> converting to GeoJSONL (WGS-84, BBL only) via Docker"
# -makevalid repairs self-intersecting polygons that BigQuery's GEOGRAPHY
# ingester would otherwise reject.  -select BBL keeps the file small;
# bq.load.geometry already uses --ignore_unknown_values for any extras.
"$container_cmd" run --rm \
  -v "${tmpdir}:/data" \
  ghcr.io/osgeo/gdal:ubuntu-small-latest \
  ogr2ogr -f GeoJSONSeq -t_srs EPSG:4326 -makevalid -select BBL \
    "/data/${geojsonl_name}" \
    "/data/${shp_rel}"

dest="${bucket}/${dest_path}"
echo ">> uploading -> ${dest}"
gcloud storage cp "$geojsonl" "$dest"

sha256="$(shasum -a 256 "$geojsonl" | awk '{print $1}')"
retrieved_at="$(date -u +%Y-%m-%d)"

cat <<EOF

────────────────────────────────────────────────────────────────────────────
Vendored @ ${retrieved_at}
  source:   ${url}
  snapshot: ${dest}
  sha256:   ${sha256}

Next:
  make bq.load.geometry
────────────────────────────────────────────────────────────────────────────
EOF
