#!/usr/bin/env bash
#
# load_pluto_to_bigquery.sh — load each vendored yearly PLUTO CSV into its own
# all-STRING table in the raw_pluto dataset.
#
# PLUTO columns drift year to year, so each release is loaded into its own table
# (raw_pluto.pluto_<version>) with a schema generated from that file's header.
# Typing everything STRING keeps the load robust; casting happens later in dbt.
# Combining the releases is a dbt concern, not done here.
#
#   make bq.load.pluto

set -euo pipefail

bucket="${RAW_BUCKET:?set RAW_BUCKET (e.g. run via 'make bq.load.pluto')}"
project="${GCP_PROJECT:?set GCP_PROJECT (e.g. run via 'make bq.load.pluto')}"
dataset="${project}:${PLUTO_DATASET:?set PLUTO_DATASET (e.g. run via 'make bq.load.pluto')}"
here="$(cd "$(dirname "$0")" && pwd)"

# Yearly snapshots are pluto/pluto_<version>.csv; skip the legacy combined file.
gcloud storage ls "${bucket}/pluto/pluto_*.csv" \
  | grep -v 'pluto_historical\.csv' \
  | while IFS= read -r uri; do
      base="$(basename "$uri" .csv)"          # e.g. pluto_25v3
      schema="${here}/schemas/${base}.json"
      # Generate the all-STRING schema if it isn't committed yet (new release).
      [[ -f "$schema" ]] || "${here}/gen_string_schema.sh" "$uri" > "$schema"

      echo ">> loading ${dataset}.${base}"
      bq load \
        --source_format=CSV \
        --skip_leading_rows=1 \
        --allow_quoted_newlines \
        --replace \
        "${dataset}.${base}" "$uri" "$schema"
    done

echo "Done. Tables in ${dataset}:"
bq ls "${dataset}"
