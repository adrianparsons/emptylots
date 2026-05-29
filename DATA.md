# Data pipeline

How raw City of New York data gets into the project and becomes the models the
frontend reads. The guiding goals are **clarity** (anyone can see where a table
came from) and **reproducibility** (the whole thing rebuilds from a clean
checkout).

## Layers

```
NYC source (data.cityofnewyork.us, DCP BYTES)
   │  vendor: download → immutable dated snapshot in GCS
   ▼
gs://nyc-pluto-historical/raw/<dataset>/<version>/<file>.csv      (raw snapshots)
   │  bq load (explicit all-STRING schema from build/schemas/)
   ▼
BigQuery native tables  (raw_dob.*, nyc_pluto_historical.pluto)  (declared in sources.yml)
   │  dbt build
   ▼
staging → intermediate → marts                                    (dbt models)
```

Raw data is **vendored**: we snapshot a copy into our own bucket rather than
querying NYC live, so rebuilds are deterministic even as NYC updates the source.
Tables are **native** (data copied into BigQuery via `bq load`), loaded from the
GCS snapshot with an explicit schema.

## Provenance

Every raw table is declared in [`dbt/models/staging/sources.yml`](dbt/models/staging/sources.yml)
with a `meta:` block recording `publisher`, `source_url`, the NYC Open Data
`dataset_id`, the `schema_file`, and the vendored `version`. This surfaces in
`dbt docs`, so the lineage from a model back to its City of New York origin is
visible without digging.

### Dataset inventory

| Source table | NYC dataset | ID | Load schema |
|---|---|---|---|
| `raw_dob.permit_issuance` | DOB Permit Issuance | `ipu4-2q9a` | `build/schemas/permit_issuance.json` |
| `raw_dob.stalled_construction` | DOB Stalled Construction Sites | `i296-73x5` | `build/schemas/stalled_construction.json` |
| `raw_dob.building` | Building Footprints | `5zhs-2jue` | `build/schemas/building.json` |
| `nyc_pluto_historical.pluto` | PLUTO (DCP BYTES, 2018–2025) | — | 8 zips → stacked CSV |
| `nyc_pluto_historical.stg_geometry` | MapPLUTO geometry | — | GeoJSON → `bq load` (GEOGRAPHY) |

The `build/schemas/*.json` files are the load-time schema — every column is
typed `STRING` on purpose, so messy NYC values never break the load. Casting and
parsing happen later, in the `stg_*` models.

## Vendoring a dataset

### Single-CSV datasets (the DOB sets)

```bash
make vendor.permits      # or vendor.stalled / vendor.building
```

This runs [`build/vendor_dataset.sh`](build/vendor_dataset.sh): downloads from
NYC, uploads to a dated, never-overwritten path (`raw/<dataset>/<YYYY-MM-DD>/`),
and prints a provenance block. Paste the relevant bits into the matching table
in `sources.yml` (set `version`), and bump the matching `*_CSV` variable in the
Makefile to the new dated path.

### PLUTO (multi-version archive)

```bash
make vendor.pluto
```

Downloads the eight yearly PLUTO releases, `csvstack`s them into one CSV, and
uploads it. (See `build/get_historical_pluto.sh`, `combine_csvs.sh`,
`cp_csv_to_bucket.sh`.)

### Geometry (`stg_geometry`)

GeoJSON with a `GEOGRAPHY` column, loaded via
`build/load_geojson_to_bigquery.sh`.

## Loading and building

```bash
make bq.load.permits      # or bq.load.stalled / bq.load.building
make dbt.build            # run + test all models
```

`bq.load.*` loads the vendored snapshot into the native `raw_dob.*` table with
`--replace` (so the table mirrors the snapshot) and the explicit JSON schema.

## Reproducing from scratch

```bash
make vendor.permits vendor.stalled vendor.building vendor.pluto
# set each version in sources.yml and each *_CSV path in the Makefile
make bq.load.permits bq.load.stalled bq.load.building
make dbt.build
```

## Known follow-ups

- **Layer separation.** dbt currently builds models *into* `nyc_pluto_historical`,
  the same dataset that holds raw vendored tables. Splitting raw landing
  (`raw_*`) from dbt-built datasets (`staging`/`marts`) would make raw vs.
  derived obvious. Deferred because the frontend reads model tables from
  BigQuery and renaming datasets would need coordinated changes.
- **Normalize PLUTO path.** The combined PLUTO CSV still lives at the bucket
  root; move it under `raw/pluto/<version>/` on the next vendoring pass.
