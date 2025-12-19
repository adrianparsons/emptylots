#!/bin/bash

# Create historical directory if it doesn't exist
mkdir -p historical

# Array of URLs
declare -A urls=(
  ["2025"]="https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/pluto/nyc_pluto_25v3_arc_csv.zip"
  ["2024"]="https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/pluto/nyc_pluto_24v4_1_arc_csv.zip"
  ["2023"]="https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/pluto/nyc_pluto_23v3_1_arc_csv.zip"
  ["2022"]="https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/pluto/nyc_pluto_22v3_arc_csv.zip"
  ["2021"]="https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/pluto/nyc_pluto_21v3_arc_csv.zip"
  ["2020"]="https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/pluto/nyc_pluto_20v8_arc_csv.zip"
  ["2019"]="https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/pluto/nyc_pluto_19v2_csv.zip"
  ["2018"]="https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/pluto/nyc_pluto_18v2_1_csv.zip"
)

# Download and unzip each file
for year in "${!urls[@]}"; do
  url="${urls[$year]}"
  filename="historical/pluto_${year}.zip"

  echo "Downloading PLUTO data for ${year}..."
  curl -L -o "$filename" "$url"

  if [ $? -eq 0 ]; then
    echo "Successfully downloaded ${filename}"
    echo "Unzipping ${filename}..."
    unzip -o "$filename" -d "historical/${year}"

    if [ $? -eq 0 ]; then
      echo "Successfully unzipped to historical/${year}"
      # Optionally remove the zip file after extraction
      # rm "$filename"
    else
      echo "Error unzipping ${filename}"
    fi
  else
    echo "Error downloading ${url}"
  fi
  echo ""
done

echo "All downloads complete!"

