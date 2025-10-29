#! /bin/bash

set -e
TILE_FILE_NAME=$1
LAYER_NAME=$2
CMD="tippecanoe -f -zg -o /usr/local/tiles/$TILE_FILE_NAME.pmtiles --projection=EPSG:4326 --extend-zooms-if-still-dropping --drop-densest-as-needed -l $LAYER_NAME /usr/local/tiles/$TILE_FILE_NAME.geojson"
IMG_TAG="ghcr.io/adrianparsons/tippecanoe:latest"

docker run --rm \
    --mount type=bind,source="$(pwd)"/tiles,target=/usr/local/tiles/ \
    $IMG_TAG bash -c "$CMD"
