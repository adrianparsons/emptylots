# Makefile for this project

bucket = gs://nyc-lots-tiles
gcproject = empty-lots

.PHONY: clean watch tiles.cors deploy build tiles_from_bq

clean:
	rm -rf dist/*
	rm -rf .parcel-cache
	rm -rf tiles/*

style:
	npx @tailwindcss/cli -i ./src/style.css -o ./dist/style.css

build:
	NODE_ENV=development npx parcel build src/index.html --log-level verbose && cp -r static dist/

build.prod:
	NODE_ENV=production npx parcel build src/index.html --log-level verbose && cp -r static dist/

watch:
	cp -r static dist/
	npx parcel

# rsync the dist directory on a remote server, ignore dotfiles
deploy: clean build.prod
	rsync -e "ssh -i ~/.ssh/id_ed25519" \
	-av --delete dist/ \
	amp926@adrianparsons.com:/home/amp926/emptylots.adrianparsons.com \
	--exclude="\.*" \
	--verbose

tiles.all_lots:
	./build/query_to_geojson.sh MapPLUTO build/all_lots.sql
	./build/geojson_to_pmtile.sh MapPLUTO.geojson MapPLUTO.pmtiles MapPLUTO

tiles.vacant:
	./build/query_to_geojson.sh vacant build/filter_vacant_lots.sql
	./build/geojson_to_pmtile.sh vacant.geojson vacant.pmtiles vacant

tiles.parking:
	./build/query_to_geojson.sh parking build/filter_parking_lots.sql
	./build/geojson_to_pmtile.sh parking.geojson parking.pmtiles parking

tiles.deploy:
	./build/cp_to_gcloud_bucket.sh tiles/*.pmtiles $(bucket) $(gcproject)

tiles.cors:
	gcloud storage buckets update $(bucket) --cors-file=config/gcloud-bucket-cors-config.json

tiles.from_bq:
	mkdir -p tiles
	./build/pull_bigquery_data_for_tiles.sh build/all_lots_with_vacancy_data.sql > tiles/lots.json
	./build/json_to_geojsonl.sh tiles/lots.json tiles/lots.geojsonl
	./build/geojson_to_pmtile.sh lots.geojsonl lots.pmtiles lots

tiles.vacant_bq:
	@test -n "$(BQ_DATASET)" || (echo "Error: BQ_DATASET is required. Usage: make tiles.vacant_bq BQ_DATASET=<your_dataset>" && exit 1)
	mkdir -p tiles
	BQ_DATASET=$(BQ_DATASET) ./build/pull_bigquery_data_for_tiles.sh build/vacant_lots_from_bq.sql > tiles/vacant.json
	./build/json_to_geojsonl.sh tiles/vacant.json tiles/vacant.geojsonl
	./build/geojson_to_pmtile.sh vacant.geojsonl vacant.pmtiles vacant

## BigQuery data loading
## Usage: make bq.load.permits CSV=local/data/DOB_Permit_Issuance.csv

bq.load.permits:
	bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines \
		empty-lots:raw_dob.permit_issuance \
		$(CSV) \
		build/schemas/permit_issuance.json

bq.load.stalled:
	bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines \
		empty-lots:raw_dob.stalled_construction \
		$(CSV) \
		build/schemas/stalled_construction.json

bq.load.building:
	bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines \
		empty-lots:raw_dob.building \
		$(CSV) \
		build/schemas/building.json

create_image.tippecanoe:
	./build/create_tippecanoe_image.sh

create_image.gdal:
	./build/create_gdal_image.sh

push_image.tippecanoe:
	docker push ghcr.io/adrianparsons/tippecanoe

push_image.gdal:
	docker push ghcr.io/adrianparsons/gdal


