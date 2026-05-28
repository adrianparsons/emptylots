#! /bin/bash

set -e
PMTILE_FILE_NAME=$1; shift   # remaining args forwarded to tippecanoe (e.g. -L '{"layer":"lots","file":"/usr/local/tiles/lots.geojson"}')
CONTAINER_CMD="${CONTAINER_CMD:-docker}"

CMD="tippecanoe \
    -f \
    -zg \
    -o /usr/local/tiles/$PMTILE_FILE_NAME \
    --projection=EPSG:4326 \
    --extend-zooms-if-still-dropping \
    --drop-densest-as-needed \
    $*"
IMG_TAG="ghcr.io/adrianparsons/tippecanoe:latest"

$CONTAINER_CMD run --rm \
    --mount type=bind,source="$(pwd)"/tiles,target=/usr/local/tiles/ \
    $IMG_TAG bash -c "$CMD"
