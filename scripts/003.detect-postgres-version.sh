#!/usr/bin/env bash

POSSIBLE_FILES=(
  ".github/workflows/ci.yaml"
  ".github/workflows/ci.yml"
  "docker-compose.yaml"
  "docker-compose.yml"
)

for POSSIBLE_FILE in "${POSSIBLE_FILES[@]}"; do
  if [ -f "$POSSIBLE_FILE" ]; then
    echo "Trying to parse existing postgres version from $POSSIBLE_FILE";

    if grep -Eo "image:\s*postgres:([0-9\.])+" "$POSSIBLE_FILE"; then
      POSTGRES_VERSION=$(grep -Eo "image:\s*postgres:([0-9\.])+" "$POSSIBLE_FILE" | cut -d: -f3)

      echo "Detected Postgres version $POSTGRES_VERSION"
      echo "POSTGRES_VERSION=${POSTGRES_VERSION}" >> "$TEMPLATE_ENV"

      exit 0;
    fi
  fi
done

echo "Unable to find any current Postgres version"
