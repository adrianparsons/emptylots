# Makefile for this project

bucket = gs://nyc-lots-tiles
gcproject = empty-lots

# Raw data bucket (vendored snapshots). The load/vendor scripts read this via
# the RAW_BUCKET env var, which the targets below pass in.
raw_bucket = gs://nyc-pluto-historical

# BigQuery datasets the raw data loads into (project is $(gcproject) above).
raw_pluto_dataset = raw_pluto
raw_dob_dataset = raw_dob

.PHONY: clean watch tiles.cors build tiles_from_bq \
	vendor.permits vendor.stalled vendor.building vendor.pluto \
	bq.load.permits bq.load.stalled bq.load.building \
	bq.load.pluto bq.load.geometry dbt.build

clean:
	rm -rf dist/*
	rm -rf .parcel-cache
	rm -rf tiles/*

style:
	npx @tailwindcss/cli -i ./src/style.css -o ./dist/style.css

build:
	NODE_ENV=development npx parcel build src/index.html --log-level verbose

build.prod:
	NODE_ENV=production npx parcel build src/index.html --log-level verbose --public-url=$(PUBLIC_URL)

watch:
	cp -r static dist/
	npx parcel

tiles.deploy:
	./build/cp_to_gcloud_bucket.sh tiles/*.pmtiles $(bucket) $(gcproject)

tiles.cors:
	gcloud storage buckets update $(bucket) --cors-file=config/gcloud-bucket-cors-config.json

tiles.from_bq:
	./build/pull_bigquery_data_for_tiles.sh build/all_lots_with_vacancy_data.sql > tiles/lots.json
	./build/pull_bigquery_data_for_tiles.sh build/parking_lots_from_bq.sql > tiles/parking.json
	./build/json_to_geojsonl.sh tiles/lots.json tiles/lots.geojsonl
	./build/json_to_geojsonl.sh tiles/parking.json tiles/parking.geojsonl
	./build/geojson_to_pmtile.sh lots.pmtiles -L lots:/usr/local/tiles/lots.geojsonl -L parking:/usr/local/tiles/parking.geojsonl

tiles.vacant_bq:
	@test -n "$(BQ_DATASET)" || (echo "Error: BQ_DATASET is required. Usage: make tiles.vacant_bq BQ_DATASET=<your_dataset>" && exit 1)
	BQ_DATASET=$(BQ_DATASET) ./build/pull_bigquery_data_for_tiles.sh build/vacant_lots_from_bq.sql > tiles/vacant.json
	./build/json_to_geojsonl.sh tiles/vacant.json tiles/vacant.geojsonl
	./build/geojson_to_pmtile.sh vacant.pmtiles -L vacant:vacant.geojsonl

## Raw data: vendor (snapshot to GCS), then bq load into native BigQuery tables.
## Source URLs for every dataset live in build/sources.tsv (looked up by slug).
##
## 1. `make vendor.<dataset>` downloads from NYC -> immutable dated path in the
##    bucket, and prints a provenance block to paste into
##    dbt/models/staging/sources.yml.
## 2. Bump the matching *_CSV path below to the dated snapshot it printed.
## 3. `make bq.load.<dataset>` loads that snapshot into raw_dob.* (schema from
##    build/schemas/, --replace so the table mirrors the snapshot).

# Vendored snapshots to load from (bump the date after each `make vendor.*`).
PERMITS_CSV  = $(raw_bucket)/raw/dob_permit_issuance/TODO/permit_issuance.csv
STALLED_CSV  = $(raw_bucket)/raw/dob_stalled_construction/TODO/stalled_construction.csv
BUILDING_CSV = $(raw_bucket)/raw/dob_building/TODO/building.csv

vendor.permits:
	RAW_BUCKET=$(raw_bucket) ./build/vendor_dataset.sh --slug dob_permit_issuance

vendor.stalled:
	RAW_BUCKET=$(raw_bucket) ./build/vendor_dataset.sh --slug dob_stalled_construction

vendor.building:
	RAW_BUCKET=$(raw_bucket) ./build/vendor_dataset.sh --slug dob_building

vendor.pluto:
	./build/get_historical_pluto.sh

bq.load.permits:
	bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines --replace \
		$(gcproject):$(raw_dob_dataset).permit_issuance \
		$(PERMITS_CSV) \
		build/schemas/permit_issuance.json

bq.load.stalled:
	bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines --replace \
		$(gcproject):$(raw_dob_dataset).stalled_construction \
		$(STALLED_CSV) \
		build/schemas/stalled_construction.json

bq.load.building:
	bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines --replace \
		$(gcproject):$(raw_dob_dataset).building \
		$(BUILDING_CSV) \
		build/schemas/building.json

# PLUTO: one all-STRING table per yearly release in raw_pluto (dataset is
# created in terraform/bigquery.tf). Combining the releases is a dbt concern.
bq.load.pluto:
	RAW_BUCKET=$(raw_bucket) GCP_PROJECT=$(gcproject) PLUTO_DATASET=$(raw_pluto_dataset) ./build/load_pluto_to_bigquery.sh

# MapPLUTO lot geometry (GEOGRAPHY) -> raw_pluto.mappluto_geometry.
bq.load.geometry:
	RAW_BUCKET=$(raw_bucket) GCP_PROJECT=$(gcproject) PLUTO_DATASET=$(raw_pluto_dataset) ./build/load_geojson_to_bigquery.sh

## dbt
dbt.build:
	cd dbt && dbt build

create_image.tippecanoe:
	./build/create_tippecanoe_image.sh

push_image.tippecanoe:
	docker push ghcr.io/adrianparsons/tippecanoe
