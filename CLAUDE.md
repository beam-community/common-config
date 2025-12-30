# CLAUDE.md

This file provides guidance for AI assistants working with the beam-community/common-config repository.

## Project Overview

This repository provides shared configuration files for all BEAM Community Elixir projects. It automatically syncs CI/CD workflows, linting configurations, and tooling standards to downstream repositories using [stordco/actions-sync](https://github.com/stordco/actions-sync).

**Key Purpose:** Single source of truth for consistent Elixir project configuration across the organization.

## Repository Structure

```
common-config/
├── .github/
│   ├── workflows/          # CI/CD for this repo itself
│   │   ├── ci.yaml         # Tests config syncing
│   │   ├── release.yaml    # Automated releases via Release Please
│   │   ├── pr.yaml         # PR title validation
│   │   └── dependabot.yaml # Auto-merge dependabot PRs
│   ├── release-please-config.json
│   └── dependabot.yml
├── scripts/                 # Detection scripts run during sync
│   ├── 001.detect-elixir-package.sh
│   ├── 002.detect-elixir-formatter-packages.sh
│   ├── 003.detect-postgres-version.sh
│   ├── 004.detect-valkey-version.sh
│   └── 005.detect-common-config-options.sh
└── templates/               # Files synced to downstream repos
    ├── .credo.exs
    ├── .formatter.exs       # Templated with {{ variables }}
    ├── .tool-versions
    └── .github/workflows/   # Workflow templates for downstream repos
```

## Technologies

- **Elixir 1.19** / **Erlang/OTP 27** (defined in `.tool-versions`)
- **GitHub Actions** for CI/CD
- **Release Please** for semantic versioning
- **Dependabot** for dependency updates
- **stordco/actions-sync** for template distribution

## Template System

Files in `templates/` use Handlebars-style templating:

| Variable | Source | Description |
|----------|--------|-------------|
| `{{ IS_MIX_PACKAGE }}` | Script 001 | `true` if `defp package do` exists in mix.exs |
| `{{ FORMATTER_IMPORTS }}` | Script 002 | Comma-separated deps (`:ecto`, `:phoenix`, etc.) |
| `{{ FORMATTER_PLUGINS }}` | Script 002 | Formatter plugins (e.g., `Phoenix.LiveView.HTMLFormatter`) |
| `{{ POSTGRES_VERSION }}` | Script 003 | PostgreSQL version from existing CI config |
| `{{ VALKEY_VERSION }}` | Script 004 | Valkey version from existing CI config |
| `{{ RELEASE_PLEASE_ENABLED }}` | Script 005 | `true` (default) or `false` from `.common-config.yml` |

**Note:** Template variables in workflow files use `$\{{` escaping to prevent GitHub Actions interpolation during sync.

## Downstream Configuration

Downstream repositories can customize sync behavior by creating a `.common-config.yml` file in the repo root:

```yaml
# .common-config.yml
release-please: false  # Disable release-please automation (default: true)
```

When `release-please: false` is set, the following files will not be synced:
- `.github/workflows/release.yaml`
- `.github/release-please-config.json`

## Commit Message Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): [#<issue>] <description>
```

**Types and their effects:**
- `feat:` - New feature (MINOR version bump)
- `fix:` - Bug fix (PATCH version bump)
- `refactor:` - Code change without feature/fix (no bump)
- `chore:` - Maintenance (no bump, excluded from changelog)
- `feat!:` / `fix!:` / `refactor!:` - Breaking change (MAJOR version bump)

**Examples:**
```
feat: Add Valkey service support
fix: [#123] Escape template variables correctly
chore(deps): Bump actions/checkout from v5 to v6
feat!: Drop support for Elixir 1.15
```

## Development Guidelines

### Adding New Templates

1. Create the file in `templates/`
2. Add header comment: `# This file is synced with beam-community/common-config. Any changes will be overwritten.`
3. Use template variables where dynamic content is needed
4. Test by running CI workflow against a target repo

### Adding Detection Scripts

Scripts in `scripts/` run in alphabetical order during sync. They:
- Must be executable bash scripts
- Write to `$TEMPLATE_ENV` to set template variables
- Should be idempotent and handle missing files gracefully

### Modifying CI Workflows

Workflow templates in `templates/.github/workflows/` support conditionals:

```yaml
{{#if IS_MIX_PACKAGE}}
# Only included for publishable packages
{{/if}}

{{#or POSTGRES_VERSION VALKEY_VERSION}}
# Only included if either service is detected
{{/or}}
```

## Code Quality Standards

The synced `.credo.exs` enforces:
- **Strict mode** enabled
- Module layout order: `moduledoc`, `behaviour`, `use`, `import`, `require`, `alias`...
- 120-character line length (in `.formatter.exs`)
- No TODO comments without addressing them

## CI Matrix (for packages)

Publishable Hex packages (`IS_MIX_PACKAGE=true`) test against:
- Elixir 1.17, 1.18, 1.19
- OTP 27

## Sync Schedule

- **Automatic:** 8th of each month at 12:08 UTC
- **On-demand:** Push to `main` branch of downstream repo's `common-config.yaml`
- **Manual:** Workflow dispatch or `repository_dispatch` event

## Release Process

Releases are fully automated:
1. Commits to `main` trigger Release Please
2. A PR is created with version bump and changelog updates
3. Merging the release PR creates:
   - Git tag: `v1.15.0`
   - Moving tags: `latest`, `v1`, `v1.15`
   - GitHub Release with changelog

## Useful Commands

```bash
# No local build/test commands - this repo contains only config files
# Changes are validated by syncing to test repos in CI

# View sync targets (from ci.yaml)
gh workflow view ci.yaml
```

## Key Files Reference

| File | Purpose |
|------|---------|
| `.github/release-please-config.json` | Release Please configuration |
| `.github/dependabot.yml` | Dependabot schedule and grouping |
| `templates/.credo.exs` | Credo linting rules |
| `templates/.formatter.exs` | Elixir formatter config (templated) |
| `templates/.tool-versions` | asdf version pinning |
| `templates/.github/workflows/ci.yaml` | CI pipeline template |
| `templates/.github/workflows/pr.yaml` | PR title validation template |

## External Dependencies

- [stordco/actions-sync](https://github.com/stordco/actions-sync) - Template sync mechanism
- [stordco/actions-elixir](https://github.com/stordco/actions-elixir) - Elixir setup action
- [google-github-actions/release-please-action](https://github.com/google-github-actions/release-please-action) - Release automation
- [stordco/actions-pr-title](https://github.com/stordco/actions-pr-title) - PR title validation
