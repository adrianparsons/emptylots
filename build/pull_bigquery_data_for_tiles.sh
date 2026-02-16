#! /bin/bash

set -e

bq query --use_legacy_sql=false  --max_rows=999999 --format=json < build/generate_vacant_data_for_geojson.sql 