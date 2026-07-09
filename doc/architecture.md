# SPEC — Terraform HCP Vault + GitHub Actions CI/CD

## 1. Overview

This project provisions an [HCP Vault](https://developer.hashicorp.com/hcp/docs/vault)
cluster and configures it for **keyless, tokenless CI/CD** from GitHub Actions using
Vault's **JWT auth method** and GitHub's **OIDC** identity tokens.

Rather than storing long-lived Vault tokens as GitHub secrets, each workflow run
exchanges its short-lived GitHub OIDC token for a scoped Vault token. Authorization is
enforced through a combination of Vault **namespaces**, **JWT roles** (bound to specific
repositories and workflows), and least-privilege **ACL policies**.

The design is **multi-namespace** and **self-service**: a central `admin` namespace owns
authentication and per-namespace role/policy provisioning, while each tenant namespace
(e.g. `tn001`) manages its own day-2 configuration in isolation.

### Goals

- Bootstrap an HCP Vault cluster (and its network) from Terraform.
- Establish GitHub Actions → Vault trust via OIDC/JWT with no static secrets.
- Enforce least privilege per repository and per workflow.
- Provide an isolated, repeatable pattern for onboarding new tenant namespaces.

---

## 2. High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│ GitHub Actions (OIDC provider)                                             │
│                                                                            │
│  namespace-admin.yml ─┐                                                    │
│  namespace-tn001.yml ─┼──► _terraform-namespace.yml (reusable)             │
│                       │        │                                           │
│                       │        │ 1. request GitHub OIDC token (JWT)        │
│                       │        ▼                                           │
└───────────────────────┼────────┼───────────────────────────────────────────┘
                        │        │ 2. exchange JWT for scoped Vault token
                        ▼        ▼
┌──────────────────────────────────────────────────────────────────────────┐
│ HCP Vault Cluster                                                          │
│                                                                            │
│  namespace: admin                                                          │
│    ├─ auth/jwt_github  (JWT auth backend, trusts GitHub OIDC)              │
│    ├─ role: github-admin            → policies: self-token-admin,          │
│    │                                             github-admin              │
│    ├─ role: github-namespace-tn001  → policies: self-token-admin,         │
│    │                                             gha-namespace-admin       │
│    ├─ policies: self-token-admin, github-admin, gha-namespace-admin       │
│    │                                                                       │
│    └─ namespace: admin/tn001                                              │
│         └─ policy: gha-namespace-admin (applied inside the child ns)      │
│                                                                            │
└──────────────────────────────────────────────────────────────────────────┘
```

### Trust flow (per workflow run)

1. A push to a namespace folder triggers the matching caller workflow.
2. The caller invokes the reusable `_terraform-namespace.yml` with a `vault_role`.
3. The runner requests a GitHub OIDC token (`id-token: write`).
4. `hashicorp/vault-action` presents the JWT to Vault's `jwt_github` auth method.
5. Vault validates the token's claims (`repository`, `workflow`) against the role's
   `bound_claims` and issues a short-lived token carrying the role's policies.
6. Terraform runs against Vault using that token; the token is revoked on completion.

---

## 3. Repository Layout

| Path | Purpose | Terraform state |
|---|---|---|
| `bootstrap/` | HCP HVN + Vault cluster + admin token + child namespace creation | Local |
| `namespace-admin/` | Day-2 config for the `admin` namespace: JWT auth, roles, policies | HCP Terraform (`nhsy-hcp-org` / `namespace-admin`) |
| `namespace-tn001/` | Day-2 config for the `admin/tn001` tenant namespace (stub, deferred) | HCP Terraform (`nhsy-hcp-org` / `namespace-tn001`) |
| `policies/` | Reusable ACL policy HCL (e.g. `gha-namespace-admin.hcl`) | — |
| `modules/` | Reusable Terraform modules for Vault secret engines & auth methods | — |
| `.github/workflows/` | Reusable + per-namespace GitHub Actions workflows | — |
| `Taskfile.yml` | Task runner wrappers for each module lifecycle | — |

Separation of concerns:

- **`bootstrap/`** is a **day-0/day-1** concern — it creates infrastructure (cluster,
  network) and the child namespaces themselves. It deliberately contains **no** policies
  or auth backends.
- **`namespace-admin/`** is a **day-2** concern — it configures authentication and
  authorization inside Vault.

### 3.1 Reusable Modules (`modules/`)

Day-2 modules (`namespace-admin/`, `namespace-tn001/`, …) provision Vault secret engines
and auth methods by calling **reusable Terraform modules** in `modules/`. Centralising this
logic keeps every namespace consistent, reduces copy-paste, and lets a tenant enable an
engine with a few lines of HCL.

Each module is self-contained (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`),
provider-agnostic about the namespace (the caller supplies a `vault` provider scoped to the
target namespace), and exposes sensible defaults.

| Module | Purpose | Key inputs | Key outputs |
|---|---|---|---|
| `modules/kv-engine` | Mount a KV v2 secrets engine | `path`, `description`, `max_versions`, `cas_required`, `delete_version_after` | `path`, `accessor` |
| `modules/pki-engine` | Mount + configure a PKI secrets engine (CA + issuing roles) | `path`, `max_lease_ttl`, `common_name`, `ttl`, `key_type`, `key_bits`, `roles` | `path`, `accessor`, `issuing_ca` |
| `modules/jwt-auth` | Mount a JWT/OIDC auth method and create bound-claim roles | `path`, `oidc_discovery_url` / `bound_issuer`, `default_lease_ttl`, `max_lease_ttl`, `roles` (`user_claim`, `bound_claims`, `token_policies`, TTLs) | `path`, `accessor`, `role_names` |

#### `modules/kv-engine` (example)

Wraps `vault_mount` (type `kv-v2`). Provides versioned key/value storage for tenant
application secrets. Defaults to `max_versions = 10` and optional check-and-set.

#### `modules/pki-engine` (example)

Wraps `vault_mount` (type `pki`) plus `vault_pki_secret_backend_root_cert` (or intermediate)
and `vault_pki_secret_backend_role` (`for_each` over `var.roles`). Issues short-lived
X.509 certificates for internal services. Enforces a bounded `max_lease_ttl`.

#### `modules/jwt-auth` (example)

Generalises the `jwt_github` backend described in §5. Wraps `vault_jwt_auth_backend` plus
`vault_jwt_auth_backend_role` (`for_each` over `var.roles`), so both the admin `jwt_github`
mount and any tenant-owned OIDC/JWT integration are provisioned from the same code path.

#### Candidate modules (recommended next)

The following are **not required for the current CI/CD flow** but round out a self-service
tenant platform; add them as demand appears:

| Module | Why | Wraps |
|---|---|---|
| `modules/hcp-tf-workspace` | Provision HCP Terraform workspaces used **only** as a remote state backend (no VCS/runs) | `tfe_workspace`, `tfe_variable` |
| `modules/acl-policy` | DRY creation of ACL policies from HCL templates | `vault_policy` |
| `modules/namespace` | Consistent child-namespace creation (used by `bootstrap/`) | `vault_namespace` |
| `modules/database-secrets` | Dynamic, short-lived DB credentials | `vault_database_secret_backend_connection`, `_role` |
| `modules/transit` | Encryption-as-a-service (encrypt/decrypt without exposing keys) | `vault_mount` (`transit`), `vault_transit_secret_backend_key` |
| `modules/approle` | Auth for non-GitHub workloads that can't use OIDC | `vault_auth_backend` (`approle`), `vault_approle_auth_backend_role` |

#### `modules/hcp-tf-workspace` (remote-state-only)

Each day-2 module keeps its state in a distinct HCP Terraform workspace (see §8). This
module standardises that workspace creation so every module's `cloud {}` backend points at
a consistently configured workspace. It is deliberately **state-backend-only**:

- `execution_mode = "local"` — Terraform runs happen in GitHub Actions, **not** in HCP
  Terraform; the workspace is used purely to store/lock remote state.
- No VCS connection and no remote plan/apply — avoids double execution and keeps the OIDC
  → Vault trust flow (§2) the single source of run auth.
- Inputs: `name`, `organization` (`nhsy-hcp-org`), `project`, `tags`, optional
  `terraform_version` (default `1.15.8` — latest stable). Outputs: `workspace_id`,
  `workspace_name`.

**Recommendation:** implement `kv-engine`, `pki-engine`, and `jwt-auth` now (they cover the
common secret-engine and auth patterns and let §5's `jwt_github` config be refactored onto a
shared module). Add `hcp-tf-workspace` alongside them so each module's HCP Terraform
backend (§8) is provisioned as code, then `acl-policy` and `namespace` next, since existing `bootstrap/` and
`policies/` logic maps directly onto them; treat `database-secrets`, `transit`, and
`approle` as on-demand.

### 3.2 HCP Terraform Provisioning (in `bootstrap/`)

The HCP Terraform objects that back the day-2 modules are provisioned **as part of the
`bootstrap/` module** (§4) — the **project**, a **team** and its **team token** (used as the
CI `TFE_TOKEN`), and the per-namespace **remote-state workspaces** (via
`modules/hcp-tf-workspace`, §3.1). This belongs in `bootstrap/` because bootstrap already
runs with **local state** and is the day-0/day-1 layer: it is what creates the remote
backends everything else depends on, resolving the chicken-and-egg.

#### Provider (added to `bootstrap/`)

The `tfe` provider is added alongside bootstrap's existing `hcp` / `random` providers:

```hcl
terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    # ... existing hcp, random ...
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.78"
    }
  }
}

provider "tfe" {
  organization = var.organization   # nhsy-hcp-org
  # token supplied via TFE_TOKEN / credentials.tfrc.json — never hardcoded
}
```

#### Resources (outline, in `bootstrap/`)

| Resource | Purpose |
|---|---|
| `tfe_project.main` | Project named after the GitHub repo (`terraform-vault-gha-cicd`) |
| `tfe_team.gha_cicd` | Team that owns the CI token |
| `tfe_team_project_access.gha_cicd` | Grants the team `admin` (or `write`) access to the project |
| `tfe_team_token.gha_cicd` | Team API token used as the `TFE_TOKEN` GitHub secret |
| `module.namespace_workspace` | `for_each` over namespaces → one `hcp-tf-workspace` per day-2 module |

```hcl
# bootstrap/ (outline)
resource "tfe_project" "main" {
  name = var.project_name          # = repository name
}

resource "tfe_team" "gha_cicd" {
  name         = "${var.project_name}-gha-cicd"
  organization = var.organization
}

resource "tfe_team_project_access" "gha_cicd" {
  access     = "admin"
  team_id    = tfe_team.gha_cicd.id
  project_id = tfe_project.main.id
}

resource "tfe_team_token" "gha_cicd" {
  team_id = tfe_team.gha_cicd.id
}

module "namespace_workspace" {
  source   = "../modules/hcp-tf-workspace"
  for_each = toset(var.namespaces)   # ["namespace-admin", "namespace-tn001"]

  name         = each.value
  organization = var.organization
  project_id   = tfe_project.main.id
  # execution_mode = "local" enforced inside the module (remote-state-only)
}
```

#### Outputs (from `bootstrap/`)

| Output | Notes |
|---|---|
| `project_id` | ID of the created project |
| `team_id` | ID of the CI team |
| `team_token` | **`sensitive = true`** — set as the `TFE_TOKEN` GitHub Actions secret |
| `workspace_ids` | Map of namespace → workspace ID |

The `team_token` output is marked `sensitive` and must be delivered to GitHub as an
**encrypted secret** (`gh secret set TFE_TOKEN`), never committed. A team holds only one
active token at a time, so re-applying rotates it.

---

## 4. Bootstrap Module (`bootstrap/`)

Provisions the underlying HCP infrastructure, the Vault namespaces, and the **HCP Terraform
objects** (project, team, team token, per-namespace remote-state workspaces — see §3.2) that
back the day-2 modules.

### Resources

- `hcp_hvn` — HashiCorp Virtual Network hosting the cluster.
- `hcp_vault_cluster` — the HCP Vault cluster (tier, region, public endpoint configurable).
- `hcp_vault_cluster_admin_token` — short-lived admin token used for initial config.
- `random_pet` — suffix to keep the cluster ID unique.
- `vault_namespace` (for_each over `var.vault_namespaces`) — creates child namespaces
  such as `tn001` under `admin`.
- `tfe_project` — HCP Terraform project named after the GitHub repo (§3.2).
- `tfe_team` + `tfe_team_project_access` — CI team with access to the project.
- `tfe_team_token` — team token exported as the `TFE_TOKEN` GitHub secret.
- `module.namespace_workspace` (`modules/hcp-tf-workspace`, for_each over the day-2
  namespaces) — remote-state-only workspaces for `namespace-admin`, `namespace-tn001`, …

### Providers

- `hashicorp/hcp` — manages the cluster and network.
- `hashicorp/vault` — points at the cluster's public endpoint, `namespace = "admin"`,
  used to create child namespaces.
- `hashicorp/tfe` (`~> 0.78`) — manages the HCP Terraform project, team, token, and
  remote-state workspaces (§3.2).

### Key inputs

| Variable | Default | Description |
|---|---|---|
| `project_id` | — | HCP project ID |
| `hvn_id` | `vault-hvn` | HVN identifier |
| `cluster_id` | `vault-cluster` | Vault cluster identifier (suffixed with a random pet) |
| `cloud_provider` | `aws` | `aws` or `azure` |
| `region` | `us-west-2` | Deployment region |
| `hvn_cidr_block` | `172.25.16.0/20` | HVN CIDR |
| `vault_tier` | `dev` | HCP Vault tier |
| `public_endpoint` | `true` | Expose a public Vault endpoint |
| `vault_namespaces` | `[]` | Child namespace paths to create under `admin` |
| `organization` | `nhsy-hcp-org` | HCP Terraform organization |
| `project_name` | `terraform-vault-gha-cicd` | HCP Terraform project name (= repo name) |
| `namespaces` | `["namespace-admin", "namespace-tn001"]` | Day-2 modules needing a remote-state workspace |

### Key outputs

- Cluster metadata: `vault_cluster_id`, `vault_public_endpoint_url`, `vault_version`,
  `vault_tier`, `region`, `cloud_provider`, `vault_cluster_state`.
- `vault_admin_token` (sensitive), `vault_env_exports` (sensitive) — used to seed the
  local Vault environment.
- `vault_namespaces` — the created child namespace paths.
- `tfe_project_id`, `tfe_team_id`, `tfe_workspace_ids` — HCP Terraform object IDs (§3.2).
- `tfe_team_token` (sensitive) — set as the `TFE_TOKEN` GitHub Actions secret.

### First-time provisioning (two-pass apply)

Because the `vault` provider cannot initialise until the cluster exists, first-time
provisioning of a **new** cluster is a two-pass operation:

1. `bootstrap:apply:hcp` — targets only the HCP + random resources to create the cluster.
2. `eval "$(task bootstrap:env)"` — export `VAULT_ADDR` / `VAULT_TOKEN`.
3. `bootstrap:apply` (or `bootstrap:apply:vault`) — creates the child namespaces.

On day-2 (cluster already exists) a single `task bootstrap:apply` is sufficient.

---

## 5. Vault JWT Auth Method & Roles (`namespace-admin/`)

This is the core of the CI/CD integration. All configuration lives in the `admin`
namespace and is applied via the `hashicorp/vault` provider (`namespace = "admin"`),
with state stored in an HCP Terraform workspace.

### 5.1 JWT auth backend — `jwt_github`

- Vault JWT auth method mounted at path `jwt_github`.
- Configured to trust **GitHub's OIDC issuer** (`https://token.actions.githubusercontent.com`),
  validating tokens signed by GitHub for Actions runs.
- Lease TTLs are configurable (`default_lease_ttl = 1h`, `max_lease_ttl = 4h`).

### 5.2 Roles

The design uses two role patterns, differentiated by which OIDC claim identifies the
caller and which claims are bound.

#### Role: `github-admin` (admin-scoped)

Used by the `namespace-admin/` Terraform itself to manage auth, roles, and policies.

- `user_claim = "repository"`
- `bound_claims = { repository = "nhsy-hcp/terraform-vault-gha-cicd" }`
- `token_policies = ["self-token-admin", "github-admin"]`

#### Role: `github-namespace-<name>` (per-namespace, via `for_each`)

One role per tenant namespace, used by that namespace's workflow to manage its own
day-2 configuration.

- `user_claim = "workflow"`
- `bound_claims = { repository = "nhsy-hcp/terraform-vault-gha-cicd", workflow = "namespace-<name>" }`
- `token_policies = ["self-token-admin", "gha-namespace-admin"]`

Binding on **both** `repository` and `workflow` ensures only the specific workflow file
for that namespace can assume the role — a run from a different workflow or fork is
rejected.

### 5.3 Claim binding summary

| Role | `user_claim` | Bound claims | Policies |
|---|---|---|---|
| `github-admin` | `repository` | `repository` | `self-token-admin`, `github-admin` |
| `github-namespace-tn001` | `workflow` | `repository`, `workflow` | `self-token-admin`, `gha-namespace-admin` |

---

## 6. Authorization — Least-Privilege ACL Policies

Three policies express the privilege model. Each grants only what its consumer needs.

### `self-token-admin`
Allows a token to manage its own lifecycle only:

- `auth/token/lookup-self` → read
- `auth/token/renew-self` → update
- `auth/token/revoke-self` → update

### `github-admin` (admin tasks only)
Exactly what `namespace-admin/` Terraform requires — namespace management, ACL policy
management, and JWT auth config/roles:

- `sys/namespaces`, `sys/namespaces/*`
- `sys/policies/acl`, `sys/policies/acl/*`
- `auth/jwt/config`, `auth/jwt/role`, `auth/jwt/role/*`

### `gha-namespace-admin` (universal, per-namespace)
A single reusable policy (`policies/gha-namespace-admin.hcl`) granting the broad set of
capabilities a namespace admin needs — auth backends, identity, policies, mounts, quotas.

Crucially, it contains **no namespace-name references**. It is created **inside each child
namespace** via a `vault` provider alias scoped to `admin/<name>`. **Namespace isolation**
itself enforces the boundary — a token operating in `admin/tn001` cannot reach
`admin/tn002` even with identical policy paths, so no cross-namespace path references are
needed.

### Isolation model

```
admin namespace
  ├─ github-admin        → can manage namespaces, JWT, policies (admin scope)
  └─ per-namespace role  → token scoped to admin/<name>, holds gha-namespace-admin
                           policy applied INSIDE that child namespace
```

---

## 7. GitHub Actions Workflows

A **reusable template** holds all logic; thin **per-namespace callers** supply only the
namespace folder and Vault role.

### `_terraform-namespace.yml` (reusable, `workflow_call`)

Inputs: `namespace` (folder), `vault_role`. Responsibilities:

1. `permissions: id-token: write` to obtain a GitHub OIDC token.
2. `hashicorp/vault-action` — JWT login against `admin` / `jwt_github` with `vault_role`,
   exporting the resulting Vault token.
3. `terraform init` / `plan` / `apply -auto-approve` in the namespace folder.
4. Revoke the Vault token via `auth/token/revoke-self` (`if: always()`).

   `hashicorp/vault-action` only performs the JWT login (it has no revoke step), so
   revocation is an explicit final step — a `curl` POST to the Vault API, guarded by
   `if: always()` so it runs even when Terraform fails:

   ```yaml
   - name: Revoke Vault token
     if: always()
     run: |
       curl -s --fail \
         --header "X-Vault-Token: ${{ env.VAULT_TOKEN }}" \
         --header "X-Vault-Namespace: admin" \
         --request POST \
         "${VAULT_ADDR}/v1/auth/token/revoke-self"
   ```

   The `admin` namespace header is required because `jwt_github` is mounted in `admin`.
   (Alternatively, `vault token revoke -self` if the `vault` CLI is on the runner.)

### Callers

| Workflow | Trigger (push paths) | `vault_role` |
|---|---|---|
| `namespace-admin.yml` | `namespace-admin/**` | `github-admin` |
| `namespace-tn001.yml` | `namespace-tn001/**` | `github-namespace-tn001` |

Each caller `uses:` the reusable workflow with `secrets: inherit`.

### Required GitHub repository configuration

Variables (GitHub Actions environment variables):
- `VAULT_ADDR` — public endpoint URL (`task bootstrap:output`)
- `TFE_TOKEN` — HCP Terraform API token for the `cloud {}` backend

---

## 8. Namespaces

| Namespace | Managed by | Contents |
|---|---|---|
| `admin` | `namespace-admin/` | `jwt_github` auth, all roles, `github-admin` + `self-token-admin` policies, per-namespace role/policy provisioning |
| `admin/tn001` | `namespace-tn001/` (stub) | Tenant day-2 config; `gha-namespace-admin` policy applied inside |

Tenant namespaces are created by `bootstrap/` but **configured** by their own day-2
modules, keeping each tenant's blast radius contained.

Each day-2 module has its **own Terraform backend / HCP Terraform workspace** so that
state is isolated per namespace:

| Module | HCP Terraform workspace | Provisioned by |
|---|---|---|
| `namespace-admin/` | `nhsy-hcp-org` / `namespace-admin` | `modules/hcp-tf-workspace` |
| `namespace-tn001/` | `nhsy-hcp-org` / `namespace-tn001` | `modules/hcp-tf-workspace` |

This isolation means a change (or state corruption) in one namespace's module cannot
affect another, and each module's `cloud {}` block references a distinct workspace.

Both the `namespace-admin` and `namespace-tn001` **remote-state workspaces are created by
the `modules/hcp-tf-workspace` module** (§3.1) — `execution_mode = "local"`, no VCS, used
only to store and lock state. This workspace provisioning runs from `bootstrap/` (or a small
dedicated `tfe/` root using local state), so the state backends exist before the day-2
modules first run. Onboarding a new tenant therefore adds one more
`module "hcp-tf-workspace"` call rather than a manually created workspace.

---

## 9. Operational Workflows (Taskfile)

Local development is driven by `Taskfile.yml`. Representative tasks:

- `deps`, `lint` — dependency checks and `pre-commit` (gitleaks, terraform fmt/tflint).
- `bootstrap:{init,lock,plan,apply,apply:hcp,apply:vault,destroy,output,env,clean}`.
- `namespace-admin:{init,lock,validate,fmt,plan,apply,destroy,output,env,clean}`.

### First-time end-to-end flow

```sh
task bootstrap:init && task bootstrap:lock
task bootstrap:apply:hcp            # create cluster (HCP + random resources)
eval "$(task bootstrap:env)"        # set VAULT_ADDR / VAULT_TOKEN
task bootstrap:apply:vault          # create child namespaces

task namespace-admin:init && task namespace-admin:lock
eval "$(task namespace-admin:env)"  # set TF_VAR_vault_addr / TF_VAR_vault_token
task namespace-admin:apply          # JWT auth, roles, policies
```

### Onboarding a new namespace (`tn002`)

1. Add `tn002` to `bootstrap/terraform.tfvars` → `task bootstrap:apply`.
2. Add `tn002` to `namespace-admin/terraform.tfvars` → `task namespace-admin:apply`
   (creates the `github-namespace-tn002` role + `gha-namespace-admin` policy).
3. Create the `namespace-tn002/` module with its scoped `vault` provider.
4. Copy `namespace-tn001.yml` → `namespace-tn002.yml`, adjusting the folder and role.

---

## 10. Security Model Summary

- **No static Vault tokens in CI** — every run authenticates via short-lived GitHub OIDC.
- **Claim binding** ties each role to a specific repository and workflow file.
- **Least-privilege policies** grant only the capabilities each consumer requires.
- **Namespace isolation** provides the tenant boundary; the reusable policy carries no
  cross-namespace references.
- **Token revocation** — Vault tokens are revoked at the end of each workflow run.
- **Secret scanning** — `gitleaks` runs via `pre-commit` to prevent committed secrets.

---

## 11. Technology Stack

| Component | Technology |
|---|---|
| Secrets platform | HCP Vault |
| IaC | Terraform (`>= 1.9, < 2.0`) |
| Providers | `hashicorp/hcp` (~> 0.112), `hashicorp/vault` (~> 5.10), `hashicorp/random` (~> 3.9) |
| CI/CD | GitHub Actions (OIDC) |
| Auth exchange | Vault JWT auth method + `hashicorp/vault-action` |
| Remote state | HCP Terraform (`namespace-admin`, `namespace-tn001`); local state (`bootstrap`) |
| Task runner | [Task](https://taskfile.dev) |
| Quality gates | `pre-commit` — gitleaks, terraform fmt, tflint |

> **Status:** Implemented — `bootstrap/` (HCP cluster + child namespaces + HCP Terraform
> project/team/token/workspaces), the reusable `modules/` (`kv-engine`, `pki-engine`,
> `jwt-auth`, `hcp-tf-workspace`, `acl-policy`, `namespace`), `namespace-admin/` (JWT auth,
> roles, policies), the `namespace-tn001/` stub, `policies/gha-namespace-admin.hcl`, and the
> GitHub Actions workflows. The on-demand candidate modules (`database-secrets`, `transit`,
> `approle`) remain unimplemented by design.
