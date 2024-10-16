# Makefile for basic project

# Symlink the folder of geojson outputs to the dist/ folder
link_json:
	ln -s ../data/json dist/json

build: link_json
	cp -r src/ dist/
	tsc

watch:
	tsc -watch

clean:
	rm -r dist/*

# rsync the dist directory on a remote server, including symlinked directory
deploy:
	rsync -av --delete dist/ \
	amp926@adrianparsons.com:/home/amp926/emptylots.adrianparsons.com \
	--exclude="\.*" \
	--verbose \
	--copy-unsafe-links
