#! /bin/bash

set -e
GEOJSON_FILE_NAME=$1
PMTILE_FILE_NAME=$2
LAYER_NAME=$3
CONTAINER_CMD="${CONTAINER_CMD:-docker}"
CMD="tippecanoe \
    -f \
    -zg \
    -o /usr/local/tiles/$PMTILE_FILE_NAME \
    --projection=EPSG:4326 \
    --extend-zooms-if-still-dropping \
    --drop-densest-as-needed \
    -l $LAYER_NAME \
    /usr/local/tiles/$GEOJSON_FILE_NAME"
IMG_TAG="ghcr.io/adrianparsons/tippecanoe:latest"

$CONTAINER_CMD run --rm \
    --mount type=bind,source="$(pwd)"/tiles,target=/usr/local/tiles/ \
    $IMG_TAG bash -c "$CMD"
