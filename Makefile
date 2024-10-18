# Makefile for this project

clean:
	rm -rf node_modules/
	rm -r dist/*

# Symlink the folder of geojson outputs to the dist/ folder
link_json:
	ln -s ../data/json dist/json

# TODO: don't copy .ts TypeScript files into dist directory
build: link_json
	cp -r src/ dist/
	tsc

watch:
	tsc -watch

# Spin up static server for local development
serve:
	python3 -m http.server -d dist/

# rsync the dist directory on a remote server, ignore dotfiles, include symlinked directory
deploy:
	rsync -av --delete dist/ \
	amp926@adrianparsons.com:/home/amp926/emptylots.adrianparsons.com \
	--exclude="\.*" \
	--verbose \
	--copy-unsafe-links

# cleans up raw data
data.clean_filter:
	 ./venv/bin/python3 scripts/basic_filter_transform.py \
	 data/Vacant_Lots_Manhattan.original.csv \
	 --output_file data/Vacant_Lots_Manhattan.number_address.csv

# selects fewer columns. not sure if we even need this.
data.limit_columns:
	 ./venv/bin/python3 scripts/limit_columns.py \
	 data/Vacant_Lots_Manhattan.number_address.csv \
	 --output_file data/Vacant_Lots_Manhattan.number_address_limit_cols.csv

# converts our csv to geojson. TODO: double-check the input file is what we want
data.csv_to_geojson:
	 ./venv/bin/python3 scripts/csv_to_geojson.py \
	 data/Vacant_Lots_Manhattan.less_columns.csv \
	 --output_file data/json/less_columns.json