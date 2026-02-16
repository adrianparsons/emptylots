#!/bin/bash
set -euo pipefail

INPUT="${1:?Usage: $0 <input.json> [output.geojsonl]}"
OUTPUT="${2:-${INPUT%.json}.geojsonl}"

jq -c '.[] | {type: "Feature", geometry: (.geometry | fromjson), properties: (del(.geometry, .geometry_1, .latitude, .longitude))}' "$INPUT" > "$OUTPUT"

echo "Wrote $(wc -l < "$OUTPUT" | tr -d ' ') features to $OUTPUT"
