#!/usr/bin/env bash

if [ -f "mix.exs" ]; then
  echo "mix.exs file detected"

  if grep -q "defp package do" mix.exs; then
    echo "Detected a package function head in mix.exs"
    echo "IS_MIX_PACKAGE=true" >> "$TEMPLATE_ENV"

    exit 0;
  fi
fi

echo "Did not detect a package function head in mix.exs"
