# Data pipeline

How raw City of New York data gets into the project and becomes the models the
frontend reads. The guiding goals are **clarity** (anyone can see where a table
came from) and **reproducibility** (the whole thing rebuilds from a clean
checkout).

## Layers

```
NYC source (data.cityofnewyork.us, DCP BYTES)
   │  vendor: download → snapshot in GCS (overwritten in place)
   ▼
gs://nyc-lots-raw-data/<type>/<file>.csv                         (raw snapshots, grouped by source type: dob/, pluto/)
   │  bq load (explicit all-STRING schema from build/schemas/)
   ▼
BigQuery native tables  (raw_dob.*, raw_pluto.*)                  (one dataset per source)
   │  dbt build
   ▼
staging → intermediate → marts                                    (dbt models)
```

Raw data is **vendored**: we snapshot a copy into our own bucket rather than
querying NYC live, so a rebuild always loads the same bytes we last pulled.
Each `make vendor.*` overwrites the snapshot in place; GCS records the upload
time (and, with object versioning enabled, the history of prior pulls).
Tables are **native** (data copied into BigQuery via `bq load`), loaded from the
GCS snapshot with an explicit schema.

## Provenance

Every raw table is declared in [`dbt/models/staging/sources.yml`](dbt/models/staging/sources.yml)
with a `meta:` block recording `publisher`, `source_url`, and the NYC Open Data
`dataset_id`. This surfaces in `dbt docs`, so the lineage from a model back to
its City of New York origin is visible without digging. (When a snapshot was
pulled is tracked by GCS, not here.)

### Dataset inventory

| Source table | NYC dataset | ID | Load schema |
|---|---|---|---|
| `raw_dob.permit_issuance` | DOB Permit Issuance | `ipu4-2q9a` | `build/schemas/permit_issuance.json` |
| `raw_dob.stalled_construction` | DOB Stalled Construction Sites | `i296-73x5` | `build/schemas/stalled_construction.json` |
| `raw_dob.building` | Building Footprints | `5zhs-2jue` | `build/schemas/building.json` |
| `raw_pluto.pluto_18v2_1` … `pluto_25v3` | PLUTO (DCP BYTES, 2018–2025) | — | one all-STRING table per release, `build/schemas/pluto_<ver>.json` |
| `raw_pluto.mappluto_geometry` | MapPLUTO geometry | — | GeoJSON → `bq load` (GEOGRAPHY) |

> **Transition note:** `nyc_pluto_historical.pluto` (a single csvstack'd table) and
> `nyc_pluto_historical.stg_geometry` still exist and feed the current dbt models.
> The per-release `raw_pluto.*` tables above are the new home; combining them into
> one logical PLUTO and repointing the models is the next branch (see follow-ups).

The `build/schemas/*.json` files are the load-time schema — every column is
typed `STRING` on purpose, so messy NYC values never break the load. Casting and
parsing happen later, in the `stg_*` models.

## Vendoring a dataset

Every source URL lives in one place — [`build/sources.tsv`](build/sources.tsv),
a tab-separated catalog with a row per fetchable file (`type`, `slug`, `url`,
`filename`, `publisher`, `dataset_id`). Both fetch scripts read it, so adding a
PLUTO release or a new dataset is a one-line edit there rather than a code change.

### Single-CSV datasets (the DOB sets)

```bash
make vendor.permits      # or vendor.stalled / vendor.building
```

This runs [`build/vendor_dataset.sh`](build/vendor_dataset.sh): downloads from
NYC and uploads to a stable path (`dob/<file>.csv`), overwriting the previous
snapshot, then prints a provenance block. No paths to bump — the matching
`*_CSV` variable in the Makefile already points at that stable path, and GCS
records the upload time (and history, with object versioning enabled).

### PLUTO (multi-version)

The eight yearly PLUTO releases are vendored as individual CSVs in the bucket
(`pluto_18v2_1.csv` … `pluto_25v3.csv`). Each is loaded into its own all-STRING
table in `raw_pluto`:

```bash
make bq.load.pluto
```

This runs [`build/load_pluto_to_bigquery.sh`](build/load_pluto_to_bigquery.sh):
for each yearly CSV it generates an all-STRING schema from the header (PLUTO
columns drift year to year — see [`build/gen_string_schema.sh`](build/gen_string_schema.sh)),
committing it to `build/schemas/pluto_<ver>.json`, then `bq load --replace`s it
into `raw_pluto.pluto_<ver>`. The releases are *not* stacked here — combining
them is a dbt concern (next branch), which keeps the per-release provenance and
avoids the csvstack artifacts the old combined table had.

### Geometry (`mappluto_geometry`)

MapPLUTO lot polygons (GeoJSON with a `GEOGRAPHY` column), loaded into
`raw_pluto.mappluto_geometry`:

```bash
make bq.load.geometry
```

## Loading and building

```bash
make bq.load.permits      # or bq.load.stalled / bq.load.building  -> raw_dob.*
make bq.load.pluto        # all yearly PLUTO releases              -> raw_pluto.*
make bq.load.geometry     # MapPLUTO geometry                      -> raw_pluto.mappluto_geometry
make dbt.build            # run + test all models
```

`bq.load.*` loads with `--replace` (so the table mirrors the snapshot) and an
explicit all-STRING schema.

## Reproducing from scratch

```bash
make vendor.permits vendor.stalled vendor.building
make bq.load.permits bq.load.stalled bq.load.building   # raw_dob.*
make bq.load.pluto bq.load.geometry                     # raw_pluto.*
make dbt.build
```

The `raw_pluto` dataset is provisioned in
[`terraform/bigquery.tf`](terraform/bigquery.tf) — `terraform apply` before the
first load.

## Known follow-ups

- **Combine + repoint PLUTO (next branch).** Union the per-release
  `raw_pluto.pluto_*` tables into one logical PLUTO in dbt
  (`dbt_utils.union_relations`, all-STRING, cast in staging), repoint `stg_lots` /
  `mart_vacant_lots` / the `build/*.sql` tile queries from `nyc_pluto_historical`
  to `raw_pluto`, then drop the old `nyc_pluto_historical.pluto` / `stg_geometry`.
- **Declare `raw_pluto` sources in dbt.** Add the per-release tables +
  `mappluto_geometry` to `sources.yml` (with provenance `meta`) as part of that
  union work.
- **Layer separation.** dbt still builds models *into* `nyc_pluto_historical`.
  Splitting dbt-built datasets (`staging`/`marts`) from raw would make raw vs.
  derived fully unambiguous. Deferred — the frontend reads model tables from
  BigQuery, so renaming those datasets needs coordinated changes.
- **Vendor the per-release CSVs reproducibly.** The yearly `pluto_<ver>.csv`
  files are already in the bucket; `get_historical_pluto.sh` downloads/unzips
  them locally but doesn't yet upload them under that naming.
