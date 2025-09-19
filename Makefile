# Makefile for this project
clean:
	rm -r dist/*

style:
	npx @tailwindcss/cli -i ./src/style.css -o ./dist/style.css

build: style
	cp -r src/*.html dist/
	cp -r data/json dist/
	tsc

watch.ts:
	tsc -watch

watch.style:
	npx @tailwindcss/cli -i ./src/style.css -o ./dist/style.css --watch

# Spin up static server for local development
serve:
	python3 -m http.server -d dist/

# rsync the dist directory on a remote server, ignore dotfiles, include symlinked directory
deploy:
	rsync -e "ssh -i ~/.ssh/id_ed25519" \
	-av --delete dist/ \
	amp926@adrianparsons.com:/home/amp926/emptylots.adrianparsons.com \
	--exclude="\.*" \
	--verbose \
	--copy-unsafe-links

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
	 --output_file data/json/emptylots.json