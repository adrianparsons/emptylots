#! /bin/bash

set -euo pipefail

QUERY_FILE=$1

bq query --apilog=stdout --use_legacy_sql=false --max_rows=999999 --format=json < $QUERY_FILE
