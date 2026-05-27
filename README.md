## Overview
Using [open data](https://opendata.cityofnewyork.us/) from NYC, see where empty lots are on a map and view Google Streetview images of them.

Published to https://empty.nyc

## Generating Map Tiles
We use [ogr2ogr](https://gdal.org/en/stable/programs/ogr2ogr.html) and [tippecanoe](https://github.com/felt/tippecanoe) to generate mbtiles. Then the `pmtiles` binary to generate [pmtiles](https://docs.protomaps.com/). The single file is hosted in a google cloud bucket.

Shape files come from the NYC Department of City Planning [MapPLUTO data set](https://www.nyc.gov/content/planning/pages/resources/datasets/mappluto-pluto-change)

eh?

