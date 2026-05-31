#!/usr/bin/env bash
#
# vendor_dataset.sh — fetch a City of New York dataset and snapshot it to GCS.
#
# Looks the dataset up by --slug in build/sources.tsv (url, filename, publisher,
# dataset_id), downloads it, and uploads it to a stable path in the raw bucket
# (<bucket>/<slug>/<file>), overwriting the previous snapshot. The bucket records
# the upload time (and full history, if object versioning is enabled), so there's
# no date to track by hand.
#
# Usage:
#   build/vendor_dataset.sh --slug dob_permit_issuance \
#     [--bucket gs://...]                 # defaults to $RAW_BUCKET

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="${here}/sources.tsv"

bucket="${RAW_BUCKET:-}"   # default from env; --bucket overrides
slug=""

die() { echo "error: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug)    slug="$2"; shift 2 ;;
    --bucket)  bucket="${2%/}"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *)         die "unknown argument: $1" ;;
  esac
done

[[ -n "$slug" ]]      || die "--slug is required"
[[ -n "$bucket" ]]    || die "set RAW_BUCKET or pass --bucket"
[[ -f "$manifest" ]]  || die "manifest not found: $manifest"

# Look up this slug's row in the catalog.
url="" filename="" publisher="" dataset_id=""
while IFS=$'\t' read -r m_type m_slug m_url m_filename m_publisher m_dataset_id || [[ -n "$m_type" ]]; do
  case "$m_type" in ''|'#'*|type) continue ;; esac
  if [[ "$m_slug" == "$slug" ]]; then
    url="$m_url"; filename="$m_filename"; publisher="$m_publisher"; dataset_id="$m_dataset_id"
    break
  fi
done < "$manifest"

[[ -n "$url" ]] || die "slug '$slug' not found in $manifest"

dest="${bucket}/${slug}/${filename}"

tmpdir="$(mktemp -d)"; trap 'rm -rf "$tmpdir"' EXIT
local_file="${tmpdir}/${filename}"

echo ">> downloading $url" >&2
curl --fail --location --progress-bar "$url" -o "$local_file"

# Cheap extras that make the source self-describing in dbt docs.
sha256="$(shasum -a 256 "$local_file" | awk '{print $1}')"
row_count="$(($(wc -l < "$local_file" | tr -d ' ') - 1))"
retrieved_at="$(date -u +%Y-%m-%d)"

echo ">> uploading to $dest" >&2
gcloud storage cp "$local_file" "$dest"

cat <<EOF

────────────────────────────────────────────────────────────────────────────
Vendored ${slug} @ ${retrieved_at}
  publisher: ${publisher}
  dataset:   ${dataset_id}
  snapshot:  ${dest}
  rows:      ${row_count}
  sha256:    ${sha256}

Next:
  make bq.load.<dataset>
────────────────────────────────────────────────────────────────────────────
EOF
