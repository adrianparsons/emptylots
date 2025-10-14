#! /bin/bash

set -e

DAL_CMD="ogr2ogr -t_srs 'EPSG:4326' -sql @/usr/local/query.sql -f GeoJSON /usr/local/tiles/vacant.geojson MapPLUTO.shp" # Transforms the map projection to EPSG:4327
DAL_TAG="gdal:1"

docker run --rm \
    --mount type=bind,source="$(pwd)"/build/filter_vacant_lots.sql,target=/usr/local/query.sql \
    --mount type=bind,source="$(pwd)"/tiles,target=/usr/local/tiles/ \
    $DAL_TAG bash -c "$DAL_CMD"
