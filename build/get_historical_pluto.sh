#!/usr/bin/env bash
#
# Fetch the historical PLUTO releases listed in build/sources.tsv (type=pluto):
# download each zip and unzip it under historical/<slug>/.   make vendor.pluto

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="${here}/sources.tsv"

[[ -f "$manifest" ]] || { echo "error: manifest not found: $manifest" >&2; exit 1; }

mkdir -p historical

while IFS=$'\t' read -r type slug url filename publisher dataset_id || [[ -n "$type" ]]; do
  # Skip blank lines, comments (#...), and the header row.
  case "$type" in ''|'#'*|type) continue ;; esac
  [[ "$type" == "pluto" ]] || continue

  zip="historical/${filename}"
  echo ">> downloading ${slug} (${url})"
  curl --fail --location -o "$zip" "$url"

  echo ">> unzipping ${zip} -> historical/${slug}/"
  unzip -o "$zip" -d "historical/${slug}"
  echo ""
done < "$manifest"

echo "All PLUTO downloads complete."
