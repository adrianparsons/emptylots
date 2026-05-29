# Data pipeline

How raw City of New York data gets into the project and becomes the models the
frontend reads. The guiding goals are **clarity** (anyone can see where a table
came from) and **reproducibility** (the whole thing rebuilds from a clean
checkout), using **dbt-native** mechanisms wherever possible.

## Layers

```
NYC source (data.cityofnewyork.us, DCP BYTES)
   │  vendor: download → immutable dated snapshot in GCS
   ▼
gs://nyc-pluto-historical/raw/<dataset>/<version>/<file>.csv      (raw snapshots)
   │  dbt-external-tables: CREATE EXTERNAL TABLE over the snapshot
   ▼
BigQuery sources  (raw_dob.*, nyc_pluto_historical.pluto)         (declared in sources.yml)
   │  dbt build
   ▼
staging → intermediate → marts                                    (dbt models)
```

Raw data is **vendored**: we snapshot a copy into our own bucket rather than
querying NYC live, so rebuilds are deterministic even as NYC updates the source.

## Provenance

Every raw table is declared in [`dbt/models/staging/sources.yml`](dbt/models/staging/sources.yml)
with a `meta:` block recording `publisher`, `source_url`, the NYC Open Data
`dataset_id`, the vendored `version`, and `sha256`. This surfaces in `dbt docs`,
so the lineage from a model back to its City of New York origin is visible
without digging.

### Dataset inventory

| Source table | NYC dataset | ID | Ingestion |
|---|---|---|---|
| `raw_dob.permit_issuance` | DOB Permit Issuance | `ipu4-2q9a` | CSV → external table |
| `raw_dob.stalled_construction` | DOB Stalled Construction Sites | `i296-73x5` | CSV → external table |
| `raw_dob.building` | Building Footprints | `5zhs-2jue` | CSV → external table |
| `nyc_pluto_historical.pluto` | PLUTO (DCP BYTES, 2018–2025) | — | 8 zips → stacked CSV → external table |
| `nyc_pluto_historical.stg_geometry` | MapPLUTO geometry | — | GeoJSON → native `bq load` (GEOGRAPHY) |

## Vendoring a dataset

### Single-CSV datasets (the DOB sets)

```bash
make vendor.permits      # or vendor.stalled / vendor.building
```

This runs [`build/vendor_dataset.sh`](build/vendor_dataset.sh): downloads from
NYC, uploads to a dated, never-overwritten path
(`raw/<dataset>/<YYYY-MM-DD>/`), and prints a provenance block. Paste that block
into the matching table in `sources.yml` — set `version`, `sha256`, and the
external `location` to the dated path.

### PLUTO (multi-version archive)

```bash
make vendor.pluto
```

Downloads the eight yearly PLUTO releases, `csvstack`s them into one CSV, and
uploads it. (See `build/get_historical_pluto.sh`, `combine_csvs.sh`,
`cp_csv_to_bucket.sh`.)

### Geometry (`stg_geometry`)

Not a CSV external table — it's GeoJSON with a `GEOGRAPHY` column, loaded
natively via `build/load_geojson_to_bigquery.sh`.

## Building the external tables and models

```bash
make dbt.stage_external   # CREATE OR REPLACE EXTERNAL TABLE for each source
make dbt.build            # run + test all models
```

`dbt.stage_external` is `dbt run-operation stage_external_sources` from the
[`dbt_external_tables`](dbt/packages.yml) package; it reads the `external:`
blocks in `sources.yml`. Re-run it after vendoring a refreshed snapshot.

## Reproducing from scratch

```bash
make vendor.permits vendor.stalled vendor.building vendor.pluto
# paste each printed provenance block into sources.yml
make dbt.stage_external
make dbt.build
```

## Known follow-ups

- **Layer separation.** dbt currently builds models *into* `nyc_pluto_historical`,
  the same dataset that holds raw vendored tables. Splitting raw landing
  (`raw_*`) from dbt-built datasets (`staging`/`marts`) would make raw vs.
  derived obvious and permissionable. Deferred because the frontend reads model
  tables from BigQuery and renaming datasets would need coordinated changes.
- **Normalize PLUTO path.** The combined PLUTO CSV still lives at the bucket
  root; move it under `raw/pluto/<version>/` on the next vendoring pass.
- The legacy `bq load` schema files in `build/schemas/` are now superseded by
  the explicit `columns:` in `sources.yml` and can be removed once the external
  tables are verified.
