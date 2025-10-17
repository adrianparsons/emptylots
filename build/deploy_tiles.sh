#! /bin/bash

set -e

gcloud storage cp tiles/*.pmtiles gs://nyc-lots-tiles/
