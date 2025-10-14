FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/adrianparsons/empty-lots"

ARG TIPPECANOE_REPO=https://github.com/felt/tippecanoe.git

RUN apt-get update && apt-get install -y \
    git \
    make \
    g++ \
    libsqlite3-dev \
    zlib1g-dev

RUN git clone ${TIPPECANOE_REPO} \
    && cd tippecanoe \
    && make -j \
    && make install
