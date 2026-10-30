# CLAUDE.md

This file provides guidance for AI assistants working with the beam-community/common-config repository.

## Project Overview

This repository provides shared configuration files for all BEAM Community Elixir projects. It automatically syncs CI/CD workflows, linting configurations, and tooling standards to downstream repositories using [beam-community/actions-sync](https://github.com/beam-community/actions-sync).

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
│   └── 004.detect-valkey-version.sh
└── templates/               # Files synced to downstream repos
    ├── AGENTS.md            # Shared AI agent guidance (templated)
    ├── CLAUDE.md            # Imports AGENTS.md and .agents/PROJECT.md
    ├── .claude/skills/      # Shared agent skills
    ├── .agents/skills       # Symlink to .claude/skills; expanded to real files on sync
    ├── .credo.exs
    ├── .formatter.exs       # Templated with {{ variables }}
    ├── .tool-versions
    └── .github/workflows/   # Workflow templates for downstream repos
```

## Technologies

- **Elixir 1.20** / **Erlang/OTP 29** (defined in `templates/.tool-versions`)
- **GitHub Actions** for CI/CD
- **Release Please** for semantic versioning
- **Dependabot** for dependency updates
- **beam-community/actions-sync** for template distribution

## Template System

Files in `templates/` use Handlebars-style templating:

| Variable | Source | Description |
|----------|--------|-------------|
| `{{ IS_MIX_PACKAGE }}` | Script 001 | `true` if `defp package do` exists in mix.exs |
| `{{ FORMATTER_IMPORTS }}` | Script 002 | Comma-separated deps (`:ecto`, `:phoenix`, etc.) |
| `{{ FORMATTER_PLUGINS }}` | Script 002 | Formatter plugins (e.g., `Phoenix.LiveView.HTMLFormatter`) |
| `{{ POSTGRES_VERSION }}` | Script 003 | PostgreSQL version from existing CI config |
| `{{ VALKEY_VERSION }}` | Script 004 | Valkey version from existing CI config |

**Note:** Every file under `templates/` is rendered with Handlebars, not just workflows. Any literal `{{` (GitHub Actions expressions, examples in Markdown) must be escaped as `\{{` (workflows use `$\{{`), or the file fails to render and is silently skipped.

## Downstream Configuration

Downstream repositories can customize sync behavior in `.github/common-config.yaml`, read by actions-sync. The most common use is opting out of specific files:

```yaml
# .github/common-config.yaml
ignore-files:
  - .github/common-config.yaml # Ignore this file itself
  - .github/workflows/release.yaml
```

Patterns are globs matched against paths relative to `templates/`. Other supported keys mirror the actions-sync inputs (`pr-enabled`, `pr-labels`, `pr-title`, `commit-message`, ...).

## Commit Message Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): [#<issue>] <description>
```

**Types and their effects:**
- `feat:` - New feature (MINOR version bump)
- `fix:` - Bug fix (PATCH version bump)
- `refactor:` - Code change without feature/fix (no bump)
- `docs:` - Documentation changes (no bump)
- `style:` - Formatting, whitespace (no bump)
- `perf:` - Performance improvement (no bump)
- `test:` - Adding or updating tests (no bump)
- `build:` - Build system or dependency changes (no bump)
- `ci:` - CI/CD configuration changes (no bump)
- `chore:` - Maintenance (no bump, excluded from changelog)
- `revert:` - Reverts a previous commit (no bump)
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

### AI Agent Configuration

`templates/AGENTS.md`, `templates/CLAUDE.md`, and the skills in `templates/.claude/skills/` give every downstream repo the same agent guidance and workflows (`pull-request`, `incorporate-feedback`, `pr-review`).

- Keep them generic. Anything true of only one repo belongs in that repo's `.agents/PROJECT.md`, which is never synced. `CLAUDE.md` imports it with `@.agents/PROJECT.md` (a missing import is a no-op) and `AGENTS.md` tells other agents to read it.
- `SKILL.md` frontmatter must start on line 1, so the sync header goes inside the frontmatter as a YAML `#` comment.
- Claude Code loads skills from `.claude/skills/`; Codex and other agents use `.agents/skills/`. `templates/.agents/skills` is a symlink, so there is one source here and actions-sync writes real copies to both locations downstream.
- In `AGENTS.md`, keep Elixir module attributes in backticks (`` `@doc` ``). Claude Code treats a bare `@path` as a file import.

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
- Elixir 1.18 on OTP 27, 1.19 on OTP 28, 1.20 on OTP 29

This covers the three most recent Elixir minor releases, each on the newest OTP it supports (see Elixir's [compatibility table](https://hexdocs.pm/elixir/compatibility-and-deprecations.html)). Single-version jobs (Credo, Dialyzer, Format, docs, production) use the newest pair. Quote matrix versions: unquoted `1.20` is the YAML float `1.2`.

## Sync Schedule

- **Automatic:** 1st of each month at 00:00 UTC
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
| `templates/.github/workflows/pr.yaml` | Commit linting and PR labeling template |
| `templates/AGENTS.md` | Shared AI agent guidance (templated) |
| `templates/.claude/skills/` | Shared agent skills |

## External Dependencies

- [beam-community/actions-sync](https://github.com/beam-community/actions-sync) - Template sync mechanism
- [erlef/setup-beam](https://github.com/erlef/setup-beam) - Elixir/OTP setup action
- [google-github-actions/release-please-action](https://github.com/google-github-actions/release-please-action) - Release automation
- [wagoid/commitlint-github-action](https://github.com/wagoid/commitlint-github-action) - Conventional commit validation
