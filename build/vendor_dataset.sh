#!/usr/bin/env bash
#
# vendor_dataset.sh — fetch a City of New York dataset and snapshot it to GCS.
#
# Looks the dataset up by --slug in build/sources.tsv (url, filename, publisher,
# dataset_id), downloads it, uploads it to a dated path in the raw bucket, and
# prints a block to paste into dbt/models/staging/sources.yml.
#
# Usage:
#   build/vendor_dataset.sh --slug dob_permit_issuance \
#     [--version 2026-05-29]              # snapshot date, defaults to today (UTC) \
#     [--bucket gs://...]                 # defaults to $RAW_BUCKET
#     [--force]                           # allow overwriting an existing version

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="${here}/sources.tsv"

bucket="${RAW_BUCKET:-}"   # default from env; --bucket overrides
version="$(date -u +%Y-%m-%d)"
slug="" force=""

die() { echo "error: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug)    slug="$2"; shift 2 ;;
    --version) version="$2"; shift 2 ;;
    --bucket)  bucket="${2%/}"; shift 2 ;;
    --force)   force=1; shift ;;
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

dest="${bucket}/raw/${slug}/${version}/${filename}"

# Dated paths are meant to be stable snapshots; don't clobber one by accident.
if [[ -z "$force" ]] && gcloud storage ls "$dest" >/dev/null 2>&1; then
  die "$dest already exists — bump --version, or pass --force to overwrite."
fi

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
Vendored ${slug} @ ${version}
  publisher: ${publisher}
  dataset:   ${dataset_id}
  snapshot:  ${dest}
  rows:      ${row_count}
  sha256:    ${sha256}

Next:
  1. In dbt/models/staging/sources.yml, set this table's meta.version: "${version}"
  2. In the Makefile, point its *_CSV variable at:
        ${dest}
  3. make bq.load.<dataset>
────────────────────────────────────────────────────────────────────────────
EOF
