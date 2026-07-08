# terraform-vault-gha-cicd

Terraform bootstrap for an HCP Vault cluster with GitHub Actions CI/CD integration.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
  ```sh
  brew tap hashicorp/tap
  brew trust hashicorp/tap
  brew install hashicorp/tap/terraform
  ```
- [Task](https://taskfile.dev/installation/)
  ```sh
  brew install go-task
  ```
- [HCP CLI](https://developer.hashicorp.com/hcp/docs/cli) authenticated (`hcp auth login`)
  ```sh
  brew install hashicorp/tap/hcp
  hcp auth login
  hcp profile init
  ```

## Setup

```sh
task deps
cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars
# edit bootstrap/terraform.tfvars with your HCP project_id and desired config
task bootstrap:init
```

## Usage

| Command | Description |
|---|---|
| `task bootstrap:plan` | Preview changes |
| `task bootstrap:apply` | Apply (interactive) |
| `task bootstrap:apply -- -auto-approve` | Apply without prompt |
| `task bootstrap:destroy` | Destroy cluster |
| `task bootstrap:output` | Show all outputs |
| `task bootstrap:env` | Print vault env exports |
| `task lint` | Run pre-commit checks |

### Set Vault environment

```sh
eval "$(task bootstrap:env)"
```

This sets `VAULT_ADDR` and `VAULT_TOKEN` in your current shell.
