#! /bin/bash

set -e

docker build -t ghcr.io/adrianparsons/gdal - < gdal.dockerfile
