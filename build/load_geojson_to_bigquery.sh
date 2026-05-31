#! /bin/bash

# Load MapPLUTO lot geometry (GEOGRAPHY, keyed by BBL) into raw_pluto from the
# vendored GeoJSONL snapshot.   make bq.load.geometry

set -e

: "${RAW_BUCKET:?set RAW_BUCKET (e.g. run via 'make bq.load.geometry')}"
: "${GCP_PROJECT:?set GCP_PROJECT (e.g. run via 'make bq.load.geometry')}"
: "${PLUTO_DATASET:?set PLUTO_DATASET (e.g. run via 'make bq.load.geometry')}"

bq load --ignore_unknown_values --source_format=NEWLINE_DELIMITED_JSON --json_extension=GEOJSON --schema="geometry:GEOGRAPHY,BBL:FLOAT64" --replace "${GCP_PROJECT}:${PLUTO_DATASET}.mappluto_geometry" "${RAW_BUCKET}/pluto/MapPLUTO.geojsonl"