LABEL org.opencontainers.image.source https://github.com/adrianparsons/empty-lots

FROM ghcr.io/osgeo/gdal:ubuntu-small-latest

ARG MAP_URL=https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/mappluto/nyc_mappluto_25v2_1_shp.zip
ARG MAP_FILENAME=maps.zip

WORKDIR /home/ubuntu

RUN apt-get update && apt-get install -y \
    wget \
    && wget ${MAP_URL} -O ${MAP_FILENAME} \
    && unzip ${MAP_FILENAME}
