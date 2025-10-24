#! /bin/bash

set -e

docker build -t ghcr.io/adrianparsons/tippecanoe -f tippecanoe.dockerfile .
