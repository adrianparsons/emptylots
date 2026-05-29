#! /bin/bash

set -e

find historical -type f -name "*.csv" | xargs csvstack > pluto_historical.csv
