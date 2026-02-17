#! /bin/bash

set -e

QUERY_FILE=$1

envsubst < $QUERY_FILE | bq query --use_legacy_sql=false --max_rows=999999 --format=json
