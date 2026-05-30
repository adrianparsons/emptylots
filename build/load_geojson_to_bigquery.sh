#! /bin/bash

# Load MapPLUTO lot geometry (GEOGRAPHY, keyed by BBL) into raw_pluto from the
# vendored GeoJSONL snapshot.   make bq.load.geometry

set -e

bq load --ignore_unknown_values --source_format=NEWLINE_DELIMITED_JSON --json_extension=GEOJSON --schema="geometry:GEOGRAPHY,BBL:FLOAT64" --replace empty-lots:raw_pluto.mappluto_geometry gs://nyc-pluto-historical/MapPLUTO.geojsonl