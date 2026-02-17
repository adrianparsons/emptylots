#! /bin/bash

set -e

QUERY_FILE=$1

bq query --use_legacy_sql=false --max_rows=999999 --format=json < $QUERY_FILE
