resource "vault_namespace" "namespaces" {
  for_each = toset(var.vault_namespaces)

  path = each.key
}

# Allows a token to manage its own lifecycle only.
module "self_token_admin_policy" {
  source = "../modules/acl-policy"

  name   = "self-token-admin"
  policy = file("${path.module}/../policies/gha-self-token-admin.hcl")
}

# Exactly what the namespace-admin Terraform requires: namespace management,
# ACL policy management, and JWT auth config/roles.
module "github_admin_policy" {
  source = "../modules/acl-policy"

  name   = "github-admin"
  policy = file("${path.module}/../policies/gha-admin.hcl")
}

# jwt_github JWT auth backend + the github-admin and per-namespace roles.
module "jwt_github" {
  source = "../modules/jwt-auth"

  path              = var.vault_auth_mount_path
  description       = "GitHub Actions OIDC JWT auth"
  default_lease_ttl = var.default_lease_ttl
  max_lease_ttl     = var.max_lease_ttl
  roles             = local.jwt_roles
}

# The universal gha-namespace-admin policy, created INSIDE each child namespace.
# The provider is already scoped to the admin namespace, so the resource-level
# namespace argument here is relative to it (each.key), yielding admin/<name>.
# Namespace isolation enforces the boundary with no cross-namespace path refs.
resource "vault_policy" "gha_namespace_admin" {
  for_each = toset(var.vault_namespaces)

  namespace = each.key
  name      = "gha-namespace-admin"
  policy    = file("${path.module}/../policies/gha-namespace-admin.hcl")
}
