#!/bin/bash

# Fail on any error.
set -euo pipefail

# Directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

TARGET_PROJECT="${GCP_PROJECT:-${KOKORO_GCP_PROJECT:-christiechen-dev}}"
GCS_BUCKET="${GCS_BUCKET:-${KOKORO_GCS_BUCKET:-${TARGET_PROJECT}-snap-test}}"
DAISY_BUCKET="${DAISY_BUCKET:-${KOKORO_DAISY_BUCKET:-${TARGET_PROJECT}-daisy-bkt}}"

TIMESTAMP=$(date +%Y%m%d%H%M%S)
DEST_IMAGE="snap-test-ubuntu2204-${TIMESTAMP}"
GCS_DEST="gs://${GCS_BUCKET}/artifacts/manual/${TIMESTAMP}/basic-snap-test.snap"

echo "================================================================="
echo "Submitting Cloud Build pipeline from Cloudtop to ${TARGET_PROJECT}"
echo "Target Image: ${DEST_IMAGE}"
echo "GCS Destination: ${GCS_DEST}"
echo "Daisy Scratch Bucket: ${DAISY_BUCKET}"
echo "================================================================="

gcloud builds submit . \
  --project="${TARGET_PROJECT}" \
  --config="daisy/cloudbuild.yaml" \
  --substitutions="_DEST_IMAGE=${DEST_IMAGE},_GCS_PACKAGE_PATH=${GCS_DEST},_DAISY_SCRATCH_BUCKET=${DAISY_BUCKET}"

echo "Cloud Build, Daisy Image Baking, and CIT Tests completed successfully!"