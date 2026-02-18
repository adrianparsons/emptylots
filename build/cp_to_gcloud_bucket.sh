#! /bin/bash

set -e
FILES=$1
GCBUCKET=$2
GCPROJECT=$3
CONTAINER_CMD="${CONTAINER_CMD:-docker}"
IMG_TAG="gcr.io/google.com/cloudsdktool/google-cloud-cli:latest"
CMD="gcloud config set project $GCPROJECT &&
    gcloud config list"

    # gcloud storage cp $FILES $GCBUCKET"

$CONTAINER_CMD run --rm \
    --mount type=bind,source="$(pwd)",target=/usr/local/ \
    $IMG_TAG bash -c "$CMD"
