## Overview
Using [open data](https://opendata.cityofnewyork.us/) from NYC, see where empty lots are on a map and view Google Streetview images of them.

Published to https://empty.nyc


## Orientation
The `Makefile` generates consumable data from raw csv files and more.

- `src/` Static HTML, CSS, TS/JS for the browser.
- `data/` Raw csvs and intermediate files.
- `static/` Data formatted for use in the browser.
- `scripts/` Python scripts for data manipulation.

## Generating Map Tiles
We use [ogr2ogr](https://gdal.org/en/stable/programs/ogr2ogr.html) and [tippecanoe](https://github.com/felt/tippecanoe) to generate mbtiles. Then the `pmtiles` binary to generate [pmtiles](https://docs.protomaps.com/). The single file is hosted in a google cloud bucket.

The shape files come from the NYC Department of City Planning [MapPLUTO data set](https://www.nyc.gov/content/planning/pages/resources/datasets/mappluto-pluto-change)

1. `ogr2ogr -t_srs 'EPSG:4326' -f GeoJSON OUTPUT.geojson MapPLUTO.shp` # Transforms the map projection to EPSG:4326
2. `tippecanoe -f -zg --extend-zooms-if-still-dropping --drop-densest-as-needed -o OUTPUT.mbtiles INPUT.geojson`
3. `pmtiles convert INTPUT.mbtiles OUTPUT.pmtiles`
