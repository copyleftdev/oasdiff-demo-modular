#!/bin/bash
set -e

BASE=api/v1/openapi.yaml
REV=api/v2/openapi.yaml

echo "Checking breaking changes..."
oasdiff breaking "$BASE" "$REV" --fail-on ERR --format text
