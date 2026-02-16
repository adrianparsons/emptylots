#! /bin/bash

set -e

bq query --use_legacy_sql=false --max_rows=999999 --format=json < build/all_lots_with_vacancy_data.sql