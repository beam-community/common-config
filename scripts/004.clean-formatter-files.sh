#!/usr/bin/env bash

if [ -f "priv/repo/migrations/.formatter.exs" ]; then
  echo "removing repo migration formatter.exs file"
  rm -f priv/repo/migrations/.formatter.exs
fi
