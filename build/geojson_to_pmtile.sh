#! /bin/bash

set -e

CMD="tippecanoe -f -zg -o /usr/local/tiles/vacant.pmtiles --projection=EPSG:4326 --extend-zooms-if-still-dropping --drop-densest-as-needed -l vacant /usr/local/tiles/vacant.geojson"
IMG_TAG="ghcr.io/adrianparsons/tippecanoe:latest"

docker run --rm \
    --mount type=bind,source="$(pwd)"/tiles,target=/usr/local/tiles/ \
    $IMG_TAG bash -c "$CMD"
