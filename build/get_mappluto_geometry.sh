#!/usr/bin/env bash
#
# get_mappluto_geometry.sh — download the MapPLUTO shapefile zip, convert it
# to GeoJSONL, and upload it to the raw bucket.
#
# Reads the first mappluto entry in build/sources.tsv, downloads the zip,
# extracts the shapefile, and converts it to a newline-delimited GeoJSON file
# (one Feature per line, WGS-84, BBL property only) before uploading to
# ${RAW_BUCKET}/${DEST} — the path bq.load.geometry reads.
#
# Requires: ogr2ogr (GDAL) — install with `brew install gdal` on macOS.
#
#   make vendor.geometry

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="${here}/sources.tsv"

bucket="${RAW_BUCKET:?set RAW_BUCKET (e.g. run via 'make vendor.geometry')}"
bucket="${bucket%/}"
dest_path="${DEST:?set DEST (e.g. run via 'make vendor.geometry')}"

command -v ogr2ogr >/dev/null 2>&1 \
  || { echo "error: ogr2ogr not found — install GDAL (brew install gdal)" >&2; exit 1; }
[[ -f "$manifest" ]] \
  || { echo "error: manifest not found: $manifest" >&2; exit 1; }

# First mappluto entry in the catalog (newest release, listed first).
slug="" url="" filename="" publisher="" dataset_id=""
while IFS=$'\t' read -r m_type m_slug m_url m_filename m_publisher m_dataset_id \
      || [[ -n "$m_type" ]]; do
  case "$m_type" in ''|'#'*|type) continue ;; esac
  if [[ "$m_type" == "mappluto" ]]; then
    slug="$m_slug"; url="$m_url"; filename="$m_filename"
    publisher="$m_publisher"; dataset_id="$m_dataset_id"
    break
  fi
done < "$manifest"

[[ -n "$slug" ]] || { echo "error: no mappluto entry found in $manifest" >&2; exit 1; }

tmpdir="$(mktemp -d)"; trap 'rm -rf "$tmpdir"' EXIT

zip="${tmpdir}/${filename}"
echo ">> downloading ${slug}"
echo "   ${url}"
curl --fail --location --progress-bar "$url" -o "$zip"

echo ">> unzipping ${zip}"
unzip -q "$zip" -d "${tmpdir}/extracted"

shp="$(find "${tmpdir}/extracted" -name "*.shp" | head -1)"
[[ -n "$shp" ]] || { echo "error: no .shp file found in zip" >&2; exit 1; }
echo ">> found shapefile: $(basename "$shp")"

geojsonl="${tmpdir}/$(basename "$dest_path")"
echo ">> converting to GeoJSONL (WGS-84, BBL only)"
# -makevalid repairs self-intersecting polygons that BigQuery's GEOGRAPHY
# ingester would otherwise reject.  -select BBL keeps the file small;
# bq.load.geometry already uses --ignore_unknown_values for any extras.
ogr2ogr -f GeoJSONSeq -t_srs EPSG:4326 -makevalid -select BBL "$geojsonl" "$shp"

dest="${bucket}/${dest_path}"
echo ">> uploading -> ${dest}"
gcloud storage cp "$geojsonl" "$dest"

sha256="$(shasum -a 256 "$geojsonl" | awk '{print $1}')"
retrieved_at="$(date -u +%Y-%m-%d)"

cat <<EOF

────────────────────────────────────────────────────────────────────────────
Vendored ${slug} @ ${retrieved_at}
  publisher: ${publisher}
  dataset:   ${dataset_id}
  snapshot:  ${dest}
  sha256:    ${sha256}

Next:
  make bq.load.geometry
────────────────────────────────────────────────────────────────────────────
EOF
