FROM ghcr.io/osgeo/gdal:ubuntu-small-latest

LABEL org.opencontainers.image.source="https://github.com/adrianparsons/empty-lots"

ARG MAP_URL=https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/mappluto/nyc_mappluto_25v4_shp.zip
ARG MAP_FILENAME=maps.zip

WORKDIR /home/ubuntu

RUN apt-get update && apt-get install -y \
    wget \
    && wget ${MAP_URL} -O ${MAP_FILENAME} \
    && unzip ${MAP_FILENAME}
