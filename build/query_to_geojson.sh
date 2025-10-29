#! /bin/bash

set -e

TILE_FILE_NAME=$1
SQL_QUERY_FILE=$2

DAL_CMD="ogr2ogr -t_srs 'EPSG:4326' -sql @/usr/local/query.sql -f GeoJSON /usr/local/tiles/$TILE_FILE_NAME.geojson MapPLUTO.shp" # Transforms the map projection to EPSG:4327
DAL_TAG="ghcr.io/adrianparsons/gdal:latest"

mkdir -p tiles

docker run --rm \
    --mount type=bind,source="$(pwd)/$SQL_QUERY_FILE",target=/usr/local/query.sql \
    --mount type=bind,source="$(pwd)"/tiles,target=/usr/local/tiles/ \
    $DAL_TAG bash -c "$DAL_CMD"
