# This file is synced with beam-community/common-config. Any changes will be overwritten.

[
  import_deps: [{{ FORMATTER_IMPORTS }}],
  inputs: ["*.{heex,ex,exs}", "{config,lib,priv,test}/**/*.{heex,ex,exs}"],
  line_length: 120,
  plugins: [{{ FORMATTER_PLUGINS }}]
]
