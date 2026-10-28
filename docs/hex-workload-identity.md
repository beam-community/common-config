# Hex Workload Identity

Hex workload identities let GitHub Actions publish to hex.pm with a short-lived OIDC token instead of the long-lived `HEX_API_KEY` secret. They are configured by hand in the beam_community organization settings on hex.pm, so this page records what exists and how to change it.

## Configured identities

Both identities live under the beam_community organization on hex.pm.

| Setting | Package publishing | Docs publishing |
|---|---|---|
| Role | Write | Write |
| Repository owner | `beam-community` | `beam-community` |
| Workflow | `production.yaml` | `publish-docs.yaml` |
| Environment | `hexpm` | `hexpm` |
| Packages | Public packages beam_community owns, no names listed | Public packages beam_community owns, no names listed |

Leaving the package names empty covers every public package beam_community owns, including packages the organization becomes an owner of later.

The allowed repositories are tracked on hex.pm, not here. A repository belongs on the list when it publishes a Hex package and receives the synced `production.yaml` and `publish-docs.yaml` workflows.

### Why these values

- **Workflow:** `release.yaml` only runs Release Please. The `mix hex.publish` step lives in `production.yaml`, which runs when Release Please creates the GitHub release. `publish-docs.yaml` runs `mix hex.publish docs` on demand.
- **Environment:** Hex requires an environment for public repositories. Its protection rules are the check GitHub runs before a publish.
- **Repositories:** Hex has no organization-wide option. Each repository must be listed, so a repository with write access cannot publish packages it was not approved for.

## Add a repository

1. Publish the package's first release with a user account or an API key. Workload identities do not create public packages.
2. Make sure the repository syncs common-config, so it has `production.yaml` and `publish-docs.yaml`.
3. Create the `hexpm` environment in the repository:

   ```bash
   gh api -X PUT repos/beam-community/<repo>/environments/hexpm
   ```

4. On hex.pm, open the beam_community organization settings, click **Edit** on both identities, and add the repository name to **Repositories**. For a private repository, add its ID after the name, found with `gh api repos/beam-community/<repo> --jq .id`.

## Pending

- Create the `hexpm` environment in each allowed repository.
- Set `environment: hexpm` and `permissions: id-token: write` on the `Hex` job in `templates/.github/workflows/production.yaml` and `templates/.github/workflows/publish-docs.yaml`, and replace `HEX_API_KEY` with the Hex OIDC exchange.
- Confirm the "Publish public packages" scope also allows `mix hex.publish docs`.
- Remove the `HEX_API_KEY` secret once a release has published through the identity.
