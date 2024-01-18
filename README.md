# Common Config

This repository contains shared code for all of our Elixir repositories. This includes configuration files for credo, dialyzer, formatting, and github actions. It syncs all files to repositories on a file change to this repository.

<!-- {x-release-please-start-version} -->

Currently at version `1.1.2`

<!-- {x-release-please-end} -->

## Directories

- `scripts` contains javascript and elixir scripts that are ran on each repository. These could be as simple as copying a file to the repository, or as advanced as changing the `mix.exs` AST to update dependencies.

- `templates` contains files that are copied or templated to the repository.
