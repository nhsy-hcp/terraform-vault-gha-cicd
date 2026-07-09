# terraform-vault-gha-cicd

Provision an [HCP Vault](https://developer.hashicorp.com/hcp/docs/vault) cluster and
configure it for **keyless, tokenless CI/CD** from GitHub Actions using Vault's JWT auth
method and GitHub's OIDC identity tokens.

Rather than storing long-lived Vault tokens as GitHub secrets, each workflow run exchanges
its short-lived GitHub OIDC token for a scoped Vault token. Authorization is enforced
through Vault **namespaces**, **JWT roles** (bound to specific repositories and workflows),
and least-privilege **ACL policies**.

See [`doc/architecture.md`](doc/architecture.md) for the full design.

## Layout

| Path | Purpose | State |
|---|---|---|
| `bootstrap/` | HCP HVN + Vault cluster + admin token, child namespaces, and HCP Terraform project/team/token + remote-state workspaces | Local |
| `namespace-admin/` | Day-2 config for the `admin` namespace: `jwt_github` auth, roles, policies | HCP Terraform (`namespace-admin`) |
| `namespace-tn001/` | Day-2 config for the `admin/tn001` tenant namespace (stub) | HCP Terraform (`namespace-tn001`) |
| `modules/` | Reusable modules: `kv-engine`, `pki-engine`, `jwt-auth`, `hcp-tf-workspace`, `acl-policy`, `namespace` | — |
| `policies/` | Reusable ACL policy HCL (`gha-namespace-admin.hcl`) | — |
| `.github/workflows/` | Reusable + per-namespace GitHub Actions workflows | — |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
  ```sh
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
  ```
- [Task](https://taskfile.dev/installation/)
  ```sh
  brew install go-task
  ```
- [HCP CLI](https://developer.hashicorp.com/hcp/docs/cli) authenticated (`hcp auth login`)
  ```sh
  brew install hashicorp/tap/hcp
  hcp auth login && hcp profile init
  ```
- [Vault CLI](https://developer.hashicorp.com/vault/install)
  ```sh
  brew install hashicorp/tap/vault
  ```

## Setup

```sh
task deps
cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars
# edit bootstrap/terraform.tfvars with your HCP project_id and desired config
```

## First-time end-to-end flow

Because the `vault` provider cannot initialise until the cluster exists, a **new** cluster is
provisioned in two passes:

```sh
task bootstrap:init && task bootstrap:lock
task bootstrap:apply:hcp             # create cluster (HCP + random resources only)
eval "$(task bootstrap:env)"         # set VAULT_ADDR / VAULT_TOKEN
task bootstrap:apply:vault           # create child namespaces
task bootstrap:apply                 # create HCP Terraform project/team/token/workspaces

task namespace-admin:init && task namespace-admin:lock
eval "$(task namespace-admin:env)"   # set TF_VAR_vault_addr / TF_VAR_vault_token
task namespace-admin:apply           # jwt_github auth, roles, policies
```

On day-2 (cluster already exists) a single `task bootstrap:apply` is sufficient.

## Usage

| Command | Description |
|---|---|
| `task bootstrap:plan` | Preview bootstrap changes |
| `task bootstrap:apply` | Apply bootstrap (interactive) |
| `task bootstrap:apply:hcp` | First-time: create only the HCP cluster + random resources |
| `task bootstrap:apply:vault` | First-time: create the Vault child namespaces |
| `task bootstrap:output` | Show all bootstrap outputs |
| `task bootstrap:env` | Print `VAULT_ADDR` / `VAULT_TOKEN` exports |
| `task bootstrap:vault-addr` | Print the Vault public endpoint URL |
| `task bootstrap:vault-token` | Copy the Vault admin token to the clipboard |
| `task bootstrap:tfe-token` | Print the HCP Terraform team token |
| `task bootstrap:gh-config` | Set the `VAULT_ADDR` variable and `TFE_TOKEN` secret on the repo |
| `task vault:ui` | Open the Vault UI in the browser |
| `task namespace-admin:plan` | Preview admin-namespace changes |
| `task namespace-admin:apply` | Apply admin-namespace config |
| `task namespace-admin:env` | Print `TF_VAR_vault_addr` / `TF_VAR_vault_token` exports |
| `task lint` | Run pre-commit checks |

Run `task --list` for the full task set.

## GitHub Actions

Terraform for each namespace runs from a reusable workflow
(`.github/workflows/_terraform-namespace.yml`) invoked by thin per-namespace callers
(`namespace-admin.yml`, `namespace-tn001.yml`). Each run exchanges a GitHub OIDC token for a
scoped Vault token via `hashicorp/vault-action` and revokes it on completion.

Required repository configuration:

- **Variable** `VAULT_ADDR` — public endpoint URL (`task bootstrap:vault-addr | gh variable set VAULT_ADDR`).
- **Secret** `TFE_TOKEN` — HCP Terraform team token for the `cloud {}` backend
  (`task bootstrap:tfe-token | gh secret set TFE_TOKEN`).

Set both at once with `task bootstrap:gh-config`. The `TFE_TOKEN` team token is
rotated on a 7-day schedule (`time_rotating` in `bootstrap/tfe.tf`); re-run the
task after each rotation to refresh the secret.

## Onboarding a new namespace (`tn002`)

1. Add `tn002` to `bootstrap/terraform.tfvars` (`vault_namespaces`) and
   `namespace-<tn002>` to `namespaces`, then `task bootstrap:apply`.
2. Add `tn002` to `namespace-admin/terraform.tfvars` (`vault_namespaces`), then
   `task namespace-admin:apply` — creates the `github-namespace-tn002` role and the
   `gha-namespace-admin` policy inside `admin/tn002`.
3. Create the `namespace-tn002/` module with its scoped `vault` provider.
4. Copy `.github/workflows/namespace-tn001.yml` → `namespace-tn002.yml`, adjusting the
   folder and role.
