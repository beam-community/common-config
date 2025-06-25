#!/usr/bin/env bash

POSSIBLE_FILES=(
  ".github/workflows/ci.yaml"
  ".github/workflows/ci.yml"
  "docker-compose.yaml"
  "docker-compose.yml"
)

for POSSIBLE_FILE in "${POSSIBLE_FILES[@]}"; do
  if [ -f "$POSSIBLE_FILE" ]; then
    echo "Trying to parse existing Valkey version from $POSSIBLE_FILE";

    if grep -Eo "image:\s*valkey/valkey:([0-9\.])+" "$POSSIBLE_FILE"; then
      VALKEY_VERSION=$(grep -Eo "image:\s*valkey/valkey:([0-9\.])+" "$POSSIBLE_FILE" | cut -d: -f3)

      echo "Detected Valkey version $VALKEY_VERSION"
      echo "VALKEY_VERSION=${VALKEY_VERSION}" >> "$TEMPLATE_ENV"

      exit 0;
    fi
  fi
done

echo "Unable to find any current Valkey version"
