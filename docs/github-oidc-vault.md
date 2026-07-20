# GitHub Actions OIDC Authentication — `admin/tn001`

Keyless authentication for GitHub Actions workflows using Vault's JWT auth
method and GitHub's OIDC identity provider. Each workflow run exchanges a
short-lived GitHub OIDC JWT for a scoped Vault token. No long-lived credentials
are stored anywhere.

## How it works

1. GitHub Actions emits a signed OIDC JWT for the running job.
2. The `hashicorp/vault-action` step presents that JWT to Vault's JWT auth
   backend at `auth/jwt_github/login`.
3. Vault validates the JWT signature against GitHub's JWKS endpoint
   (`https://token.actions.githubusercontent.com`), checks the audience and
   bound claims, then returns a scoped Vault token.
4. The workflow uses the Vault token for the duration of the job and revokes it
   on completion.

Bound claims enforce that only a specific repository and workflow can
authenticate. There are no long-lived Vault tokens or GitHub secrets involved.

## Prerequisites

| Tool | Purpose |
|---|---|
| `vault` | All auth configuration operations |

Environment variables required for all `vault` commands in this guide:

```sh
export VAULT_ADDR="https://vault-training-cluster-pegasus-public-vault-f6816f27.65ed0d62.z1.hashicorp.cloud:8200"
export VAULT_TOKEN="<token-with-admin-tn001-rights>"
export VAULT_NAMESPACE="admin/tn001"
```

> **Token scope:** The token must have policies effective within `admin/tn001`.
> A root token or a token with `sys/auth/*` and `sys/policies/acl/*` capability
> in this namespace is required. A token scoped to a sibling or child namespace
> will not have the necessary access.

---

## 1. Enable the JWT Auth Backend

```sh
vault auth enable -path=jwt_github jwt
```

Verify:

```sh
vault auth list
```

---

## 2. Configure the JWT Backend

Set the GitHub OIDC discovery URL and bound issuer. Vault fetches the JWKS
public keys from the discovery URL automatically — no manual key rotation is
required.

```sh
vault write auth/jwt_github/config \
  oidc_discovery_url="https://token.actions.githubusercontent.com" \
  bound_issuer="https://token.actions.githubusercontent.com"
```

Tune the mount-level token TTLs. These cap all tokens issued by this backend
regardless of role-level settings:

```sh
vault auth tune \
  -default-lease-ttl=10m \
  -max-lease-ttl=10m \
  jwt_github
```

Verify:

```sh
vault read auth/jwt_github/config
vault read sys/auth/jwt_github/tune
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

## 4. Create the JWT Role

The role `github-namespace-tn001` binds authentication to:

- A specific GitHub repository (`nhsy-hcp/terraform-vault-gha-cicd`)
- A specific workflow name (`namespace-tn001`, i.e. the `.github/workflows/namespace-tn001.yml` filename without extension)
- The organisation audience (`https://github.com/nhsy-hcp`)

```sh
vault write auth/jwt_github/role/github-namespace-tn001 \
  role_type="jwt" \
  user_claim="workflow" \
  bound_audiences="https://github.com/nhsy-hcp" \
  bound_claims_type="string" \
  bound_claims=repository=nhsy-hcp/terraform-vault-gha-cicd \
  bound_claims=workflow=namespace-tn001 \
  token_policies="gha-namespace-admin,self-token-admin"
```

### Bound claims reference

| Claim | Value | Purpose |
|---|---|---|
| `aud` (audience) | `https://github.com/nhsy-hcp` | Scopes auth to this GitHub organisation |
| `repository` | `nhsy-hcp/terraform-vault-gha-cicd` | Restricts to this repository only |
| `workflow` | `namespace-tn001` | Restricts to this specific workflow file |

> The `workflow` claim contains the workflow filename without the `.yml`
> extension. If the workflow file is renamed, this role must be updated to
> match.
> The `apply` job is additionally gated at the GitHub Actions level
> (`github.ref == 'refs/heads/main'`) — branch restriction is enforced by the
> workflow, not inside Vault. To enforce branch restriction at the Vault level,
> add a `ref` bound claim (see section 7).

---

## 5. Verify the Configuration

```sh
vault read auth/jwt_github/config
vault list auth/jwt_github/role
vault read auth/jwt_github/role/github-namespace-tn001
```

Expected role output includes:

```text
bound_audiences        [https://github.com/nhsy-hcp]
bound_claims           map[repository:[nhsy-hcp/terraform-vault-gha-cicd] workflow:[namespace-tn001]]
bound_claims_type      string
token_policies         [self-token-admin gha-namespace-admin]
token_ttl              0s
token_max_ttl          0s
user_claim             workflow
```

> `token_ttl` and `token_max_ttl` show `0s` when the role inherits the
> mount-level tune values (`10m` / `10m`). This is expected — the effective
> limits are enforced by the mount tune, not stored on the role itself.

---

## 6. Update Bound Claims

### Rename the workflow

If `.github/workflows/namespace-tn001.yml` is renamed, update the `workflow`
bound claim:

```sh
vault write auth/jwt_github/role/github-namespace-tn001 \
  bound_claims=repository=nhsy-hcp/terraform-vault-gha-cicd \
  bound_claims=workflow=<new-workflow-name>
```

### Add a branch restriction at Vault level

To enforce that only runs from `refs/heads/main` can authenticate (in addition
to the GHA-level gate):

```sh
vault write auth/jwt_github/role/github-namespace-tn001 \
  bound_claims=repository=nhsy-hcp/terraform-vault-gha-cicd \
  bound_claims=workflow=namespace-tn001 \
  bound_claims=ref=refs/heads/main
```

> Adding a `ref` bound claim will block `workflow_dispatch` runs triggered from
> non-main branches. Remove it if manual dispatch from feature branches is
> required.

---

## 7. Disable / Cleanup

Revoke all tokens currently issued by this auth mount:

```sh
vault token revoke -mode=path auth/jwt_github
```

Disable the auth backend entirely (also revokes all outstanding tokens issued
by it):

```sh
vault auth disable jwt_github
```

Delete individual policies if the mount is being removed:

```sh
vault policy delete gha-namespace-admin
vault policy delete self-token-admin
```
