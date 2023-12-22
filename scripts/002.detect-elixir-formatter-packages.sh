#!/usr/bin/env bash

# This file is responsible for detecting what deps and plugins are available for
# the Elixir .formatter.exs file. To add a value in `import_deps`, add the package
# name to the MIX_PACKAGES array below.

MIX_PACKAGES=("ecto" "ecto_sql" "kafee" "open_api_spex" "patch" "phoenix" "stream_data" "typed_struct")

# We iterate over all of the MIX_PACKAGES and check if they exist in the mix.lock file.
# If they do, we add them to the FORMATTER_PACKAGES array.
FORMATTER_PACKAGES=()

if [ -f "mix.lock" ]; then
  echo "mix.lock file detected"

  for package in "${MIX_PACKAGES[@]}"; do
    if grep -q "  \"${package}\": {" mix.lock; then
      echo "${package} detected in mix.lock file"
      FORMATTER_PACKAGES+=(":${package}")
    else
      echo "${package} not detected in mix.lock file"
    fi
  done
fi

# Next we do some custom detection for formatter plugin modules. This is not
# really reusable because there is no good way to convert Phoenix.LiveView.HTMLFormatter
# to :phoenix_live_view. Therefor it's all manually written out.
FORMATTER_MODULES=()

if [ -f "mix.lock" ]; then
  if grep -q ":phoenix_live_view," mix.lock; then
    echo "phoenix_live_view detected in mix.lock file"
    FORMATTER_MODULES+=("Phoenix.LiveView.HTMLFormatter")
  fi
fi

# And lastly, we template out all of the detected variables above into a comma separated
# list and add them as template variables.
FORMATTER_IMPORTS=$(printf "%s, " "${FORMATTER_PACKAGES[@]}" | cut -d "," -f 1-${#FORMATTER_PACKAGES[@]})
echo "FORMATTER_IMPORTS=${FORMATTER_IMPORTS}" >> "$TEMPLATE_ENV"

FORMATTER_PLUGINS=$(printf "%s, " "${FORMATTER_MODULES[@]}" | cut -d "," -f 1-${#FORMATTER_MODULES[@]})
echo "FORMATTER_PLUGINS=${FORMATTER_PLUGINS}" >> "$TEMPLATE_ENV"
