#! /bin/bash

set -e

find historical -type f -name "*.csv" | xargs csvstack > historical/pluto_historical.csv