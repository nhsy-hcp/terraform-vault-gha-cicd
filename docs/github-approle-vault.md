# GitHub Actions AppRole Authentication — `admin/tn001`

Authentication for GitHub Actions workflows using Vault's AppRole auth method.
Each workflow run exchanges a pre-configured `role_id` and a short-lived
`secret_id` for a scoped Vault token.

Unlike the OIDC approach, AppRole requires two GitHub secrets (`VAULT_ROLE_ID`
and `VAULT_SECRET_ID`) to be stored in the repository. The `role_id` is
long-lived; the `secret_id` should be rotated regularly via the TTL or manually.

## How it works

1. The GitHub Actions workflow reads `VAULT_ROLE_ID` and `VAULT_SECRET_ID` from
   GitHub repository secrets.
2. The `hashicorp/vault-action` step POSTs both values to Vault's AppRole auth
   backend at `auth/approle/login`.
3. Vault validates the credentials, checks the role's bound constraints, then
   returns a scoped Vault token.
4. The workflow uses the Vault token for the duration of the job and revokes it
   on completion.

No GitHub OIDC token or JWKS endpoint is involved. Access control is enforced
entirely through the AppRole role configuration and the policies bound to it.

## Prerequisites

| Tool | Purpose |
|---|---|
| `vault` | All auth configuration operations |
| `gh` | Store `VAULT_ROLE_ID` and `VAULT_SECRET_ID` as repository secrets |

Environment variables required for all `vault` commands in this guide:

```sh
export VAULT_ADDR="https://vault-training-cluster-pegasus-public-vault-f6816f27.65ed0d62.z1.hashicorp.cloud:8200"
export VAULT_TOKEN="<token-with-admin-tn001-rights>"
export VAULT_NAMESPACE="admin/tn001"
```

> **Token scope:** The token must have policies effective within `admin/tn001`.
> A root token or a token with `sys/auth/*` and `sys/policies/acl/*` capability
> in this namespace is required.

---

## 1. Enable the AppRole Auth Backend

```sh
vault auth enable -path=approle approle
```

Verify:

```sh
vault auth list
```

---

## 2. Configure the AppRole Backend

Tune the mount-level token TTLs. These cap all tokens issued by this backend
regardless of role-level settings:

```sh
vault auth tune \
  -default-lease-ttl=10m \
  -max-lease-ttl=10m \
  approle
```

Verify:

```sh
vault read sys/auth/approle/tune
```

---

## 3. Write ACL Policies

Two policies are required. Both ship with this repository under `policies/`.

**`gha-namespace-admin`** — grants the workflow full administrative access
within `admin/tn001`: mount lifecycle, auth backends, PKI, identity, and ACL
policies. See [`policies/gha-namespace-admin.hcl`](../policies/gha-namespace-admin.hcl).

```sh
vault policy write gha-namespace-admin policies/gha-namespace-admin.hcl
```

**`self-token-admin`** — allows a token to look up, renew, and revoke itself
only. Also grants `auth/token/create`, which the Vault Terraform provider
requires to scope child tokens to the target namespace. See
[`policies/gha-self-token-admin.hcl`](../policies/gha-self-token-admin.hcl).

```sh
vault policy write self-token-admin policies/gha-self-token-admin.hcl
```

Verify:

```sh
vault policy list
vault policy read gha-namespace-admin
vault policy read self-token-admin
```

---

## 4. Create the AppRole Role

The role `github-namespace-tn001` issues tokens scoped to the two policies
above. The `secret_id_ttl` limits how long each generated secret ID remains
valid; `token_ttl` and `token_max_ttl` are capped further by the mount tune.

```sh
vault write auth/approle/role/github-namespace-tn001 \
  bind_secret_id=true \
  secret_id_ttl=24h \
  token_ttl=10m \
  token_max_ttl=10m \
  token_policies="gha-namespace-admin,self-token-admin"
```

### Role parameter reference

| Parameter | Value | Purpose |
|---|---|---|
| `bind_secret_id` | `true` | Requires a valid `secret_id` on every login |
| `secret_id_ttl` | `24h` | Secret IDs expire after 24 hours; rotate at least this often |
| `token_ttl` | `10m` | Lifetime of issued tokens |
| `token_max_ttl` | `10m` | Hard ceiling; tokens cannot be renewed beyond this |
| `token_policies` | `gha-namespace-admin,self-token-admin` | Policies attached to every issued token |

---

## 5. Retrieve Role ID and Secret ID

The `role_id` is a stable identifier for the role and is safe to store as a
non-sensitive GitHub variable. The `secret_id` is a single-use or TTL-bound
credential and must be treated as a secret.

**Retrieve the role ID:**

```sh
vault read auth/approle/role/github-namespace-tn001/role-id
```

**Generate a new secret ID:**

```sh
vault write -f auth/approle/role/github-namespace-tn001/secret-id
```

**Store both as GitHub repository secrets:**

```sh
gh secret set VAULT_ROLE_ID   --body "<role_id value>"
gh secret set VAULT_SECRET_ID --body "<secret_id value>"
```

> The `secret_id` is shown only once at generation time. Store it immediately.
> If lost, generate a new one — old secret IDs cannot be retrieved.

---

## 6. GitHub Actions Workflow

Add the following step to your workflow. The `id-token: write` permission is
**not** required (unlike OIDC). No other permissions changes are needed.

```yaml
- name: Import Secrets
  id: import-secrets
  uses: hashicorp/vault-action@v2
  with:
    url: ${{ vars.VAULT_ADDR }}
    namespace: admin/tn001
    method: approle
    roleId: ${{ secrets.VAULT_ROLE_ID }}
    secretId: ${{ secrets.VAULT_SECRET_ID }}
    secrets: |
      secret/data/ci/example key | MY_SECRET
```

### Full job example

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Import Secrets
        id: import-secrets
        uses: hashicorp/vault-action@v2
        with:
          url: ${{ vars.VAULT_ADDR }}
          namespace: admin/tn001
          method: approle
          roleId: ${{ secrets.VAULT_ROLE_ID }}
          secretId: ${{ secrets.VAULT_SECRET_ID }}
          secrets: |
            secret/data/ci/example key | MY_SECRET

      - name: Use secret
        run: echo "secret is masked in logs"
        env:
          MY_SECRET: ${{ steps.import-secrets.outputs.MY_SECRET }}
```

---

## 7. Verify the Configuration

```sh
vault read auth/approle/role/github-namespace-tn001
vault list auth/approle/role
```

Expected output includes:

```text
bind_secret_id         true
secret_id_ttl          24h
token_max_ttl          10m
token_policies         [gha-namespace-admin self-token-admin]
token_ttl              10m
```

Test login manually to confirm credentials work end-to-end:

```sh
ROLE_ID=$(vault read -field=role_id auth/approle/role/github-namespace-tn001/role-id)
SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/github-namespace-tn001/secret-id)

vault write auth/approle/login \
  role_id="$ROLE_ID" \
  secret_id="$SECRET_ID"
```

A valid Vault token in the response confirms the setup is correct.

---

## 8. Secret ID Rotation

Secret IDs expire after `secret_id_ttl` (24h by default). Rotate them before
they expire to avoid workflow authentication failures.

**Generate a replacement secret ID and update the GitHub secret:**

```sh
NEW_SECRET_ID=$(vault write -f -field=secret_id \
  auth/approle/role/github-namespace-tn001/secret-id)

gh secret set VAULT_SECRET_ID --body "$NEW_SECRET_ID"
```

> Automating rotation via a scheduled GitHub Actions workflow (using a
> bootstrap token with limited `auth/approle/role/.../secret-id` capability)
> is recommended for production use.

**List active secret ID accessors (to audit or revoke individual IDs):**

```sh
vault list auth/approle/role/github-namespace-tn001/secret-id
```

**Revoke a specific secret ID by accessor:**

```sh
vault write auth/approle/role/github-namespace-tn001/secret-id-accessor/destroy \
  secret_id_accessor="<accessor>"
```

---

## 9. Disable / Cleanup

Revoke all tokens currently issued by this auth mount:

```sh
vault token revoke -mode=path auth/approle
```

Disable the auth backend entirely (also revokes all outstanding tokens issued
by it):

```sh
vault auth disable approle
```

Delete individual policies if the mount is being removed:

```sh
vault policy delete gha-namespace-admin
vault policy delete self-token-admin
```
