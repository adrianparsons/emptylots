# Makefile for this project

bucket = gs://nyc-lots-tiles
gcproject = empty-lots

.PHONY: clean watch tiles.cors build tiles_from_bq \
	vendor.permits vendor.stalled vendor.building vendor.pluto \
	dbt.deps dbt.stage_external dbt.build

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
	mkdir -p tiles
	./build/pull_bigquery_data_for_tiles.sh build/all_lots_with_vacancy_data.sql > tiles/lots.json
	./build/pull_bigquery_data_for_tiles.sh build/parking_lots_from_bq.sql > tiles/parking.json
	./build/json_to_geojsonl.sh tiles/lots.json tiles/lots.geojsonl
	./build/json_to_geojsonl.sh tiles/parking.json tiles/parking.geojsonl
	./build/geojson_to_pmtile.sh lots.pmtiles -L lots:/usr/local/tiles/lots.geojsonl -L parking:/usr/local/tiles/parking.geojsonl

tiles.vacant_bq:
	@test -n "$(BQ_DATASET)" || (echo "Error: BQ_DATASET is required. Usage: make tiles.vacant_bq BQ_DATASET=<your_dataset>" && exit 1)
	mkdir -p tiles
	BQ_DATASET=$(BQ_DATASET) ./build/pull_bigquery_data_for_tiles.sh build/vacant_lots_from_bq.sql > tiles/vacant.json
	./build/json_to_geojsonl.sh tiles/vacant.json tiles/vacant.geojsonl
	./build/geojson_to_pmtile.sh vacant.pmtiles -L vacant:vacant.geojsonl

## Raw data: vendor (snapshot to GCS) then expose as dbt external tables.
##
## 1. Vendor a dataset (download from NYC -> immutable dated path in the bucket).
##    Each target prints a provenance block to paste into
##    dbt/models/staging/sources.yml (set `version` + the external `location`).
## 2. Run `make dbt.stage_external` to (re)create the BigQuery external tables.

vendor.permits:
	./build/vendor_dataset.sh \
		--slug dob_permit_issuance \
		--filename permit_issuance.csv \
		--publisher 'NYC Department of Buildings' \
		--dataset-id ipu4-2q9a \
		--url 'https://data.cityofnewyork.us/api/views/ipu4-2q9a/rows.csv?accessType=DOWNLOAD'

vendor.stalled:
	./build/vendor_dataset.sh \
		--slug dob_stalled_construction \
		--filename stalled_construction.csv \
		--publisher 'NYC Department of Buildings' \
		--dataset-id i296-73x5 \
		--url 'https://data.cityofnewyork.us/api/views/i296-73x5/rows.csv?accessType=DOWNLOAD'

vendor.building:
	./build/vendor_dataset.sh \
		--slug dob_building \
		--filename building.csv \
		--publisher 'NYC DOITT' \
		--dataset-id 5zhs-2jue \
		--url 'https://data.cityofnewyork.us/api/views/5zhs-2jue/rows.csv?accessType=DOWNLOAD'

vendor.pluto:
	./build/get_historical_pluto.sh
	./build/combine_csvs.sh
	./build/cp_csv_to_bucket.sh

## dbt
dbt.deps:
	cd dbt && dbt deps

dbt.stage_external: dbt.deps
	cd dbt && dbt run-operation stage_external_sources

dbt.build:
	cd dbt && dbt build

create_image.tippecanoe:
	./build/create_tippecanoe_image.sh

push_image.tippecanoe:
	docker push ghcr.io/adrianparsons/tippecanoe
