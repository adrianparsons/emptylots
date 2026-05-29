#! /bin/bash

set -e

bq load --ignore_unknown_values --source_format=NEWLINE_DELIMITED_JSON --json_extension=GEOJSON --schema="geometry:GEOGRAPHY,BBL:FLOAT64" nyc_pluto_historical.stg_geometry gs://nyc-pluto-historical/MapPLUTO.geojsonl