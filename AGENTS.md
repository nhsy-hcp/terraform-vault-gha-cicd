# AGENTS.md

Agent instructions for `terraform-vault-gha-cicd`.

## Environment Setup

Before running any Terraform or Vault commands, export the required environment variables:

```sh
eval "$(task bootstrap:env)"        # sets VAULT_ADDR and VAULT_TOKEN
eval "$(task namespace-admin:env)"  # sets TF_VAR_vault_addr and TF_VAR_vault_token
```

## Repository Layout

| Path | Purpose |
|---|---|
| `bootstrap/` | HCP cluster, child namespaces, HCP Terraform workspaces |
| `namespace-admin/` | `admin` namespace: JWT auth, roles, policies |
| `namespace-tn001/` | `admin/tn001` tenant namespace |
| `modules/` | Reusable modules: `kv-engine`, `pki-engine`, `pki-role`, `pki-intermediate`, `jwt-auth`, `hcp-tf-workspace`, `acl-policy`, `namespace` |
| `policies/` | ACL policy HCL files |
| `scripts/` | Bash helper scripts (all must pass `shellcheck`) |
| `.github/workflows/` | Reusable + per-namespace GitHub Actions workflows |

## Task Commands

```sh
task deps                        # check required dependencies
task lint                        # run all pre-commit checks (terraform fmt, yamllint, gitleaks, tflint)

task bootstrap:env               # print VAULT_ADDR / VAULT_TOKEN exports
task bootstrap:plan              # preview bootstrap changes
task bootstrap:apply             # apply bootstrap (interactive)
task bootstrap:output            # show all bootstrap outputs
task bootstrap:gh-config         # set VAULT_ADDR variable and TFE_TOKEN secret on the GitHub repo

task namespace-admin:plan        # preview admin-namespace changes
task namespace-admin:init        # initialise Terraform for namespace-admin
task namespace-tn001:plan        # preview tn001 namespace changes
task namespace-tn001:init        # initialise Terraform for namespace-tn001

task pki:test                    # run both PKI issue and sign endpoint tests
task pki:test:issue              # test PKI issue endpoint (Vault generates key + cert)
task pki:test:sign               # test PKI sign endpoint (local CSR signed by Vault)
task pki:int:chain               # fetch intermediate CA cert and build .tmp/ca-chain.pem

task vault:ui                    # open Vault UI in browser
```

Run `task --list` for the full task set.

## Linting & Verification

Always run before proposing a commit:

```sh
task lint
```

This runs: `terraform fmt`, `yamllint`, `gitleaks`, `shellcheck`, and `tflint`.

`terraform fmt` may auto-fix files — re-stage and recommit if it does.

## GitHub Actions

Workflows use keyless OIDC auth: GitHub OIDC token → scoped Vault token via `hashicorp/vault-action`. No long-lived tokens are stored.

- Reusable workflow: `.github/workflows/_terraform-namespace.yml`
- Per-namespace callers: `namespace-admin.yml`, `namespace-tn001.yml`
- Job names: `lint` → `deploy` (not `apply`)

Required repo config:
- **Variable** `VAULT_ADDR` — set via `task bootstrap:gh-config`
- **Secret** `TFE_TOKEN` — set via `task bootstrap:gh-config`

## State Backend

All workspaces use HCP Terraform for remote state (`execution_mode = "local"`). Plans and applies run in GHA, not in HCP Terraform cloud runners.

## tfvars Convention

- `terraform.tfvars` is git-ignored — do not use it.
- Use `terraform.auto.tfvars` for committed variable files (e.g., `namespace-tn001/terraform.auto.tfvars`).

## PKI Module Notes

When adding new fields to the `pki-role` module:
1. Add variable to `modules/pki-role/variables.tf`
2. Wire it in `modules/pki-role/main.tf`
3. Add `optional(...)` attribute to `variable "pki_roles"` in `namespace-tn001/variables.tf`
4. Pass it through in `namespace-tn001/pki.tf`

Test after apply with `task pki:test`.

## Temporary Files

Use `.tmp/` within the project root. This directory is git-ignored.
