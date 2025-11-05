# Makefile for this project

bucket = gs://nyc-lots-tiles

.PHONY: clean watch tiles.cors deploy build

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
	./build/geojson_to_pmtile.sh MapPLUTO MapPLUTO

tiles.vacant:
	./build/query_to_geojson.sh vacant build/filter_vacant_lots.sql
	./build/geojson_to_pmtile.sh vacant vacant

tiles.parking:
	./build/query_to_geojson.sh parking build/filter_parking_lots.sql
	./build/geojson_to_pmtile.sh parking parking

tiles.deploy:
	gcloud storage cp tiles/*.pmtiles $(bucket)

tiles.cors:
	gcloud storage buckets update $(bucket) --cors-file=config/gcloud-bucket-cors-config.json

create_image.tippecanoe:
	./build/create_tippecanoe_image.sh

create_image.gdal:
	./build/create_gdal_image.sh

push_image.tippecanoe:
	docker push ghcr.io/adrianparsons/tippecanoe

push_image.gdal:
	docker push ghcr.io/adrianparsons/gdal

data: data.clean_filter data.limit_columns data.split_by_borough data.csv_to_geojson

# cleans up raw data
data.clean_filter:
	 ./venv/bin/python3 scripts/basic_filter_transform.py \
	 data/Vacant_Lots_20250906.csv \
	 --output_file data/vacant_lots_filtered.csv

# selects fewer columns. not sure if we even need this.
data.limit_columns:
	 ./venv/bin/python3 scripts/limit_columns.py \
	 data/vacant_lots_filtered.csv \
	 --output_file data/vacant_lots_filtered_limit_cols.csv

data.split_by_borough:
	./venv/bin/python3 scripts/split_by_borough.py \
	data/vacant_lots_filtered_limit_cols.csv \
	--output_prefix data/vacant_borough

# converts our csv to geojson. TODO: double-check the input file is what we want
data.csv_to_geojson:
	 ./venv/bin/python3 scripts/csv_to_geojson.py \
	 data/vacant_lots_filtered_limit_cols.csv \
	 --output_file static/emptylots.json