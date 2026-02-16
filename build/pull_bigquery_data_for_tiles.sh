#! /bin/bash

set -e

QUERY=$1

bq query --use_legacy_sql=false --max_rows=999999 --format=json < $1
