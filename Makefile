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
