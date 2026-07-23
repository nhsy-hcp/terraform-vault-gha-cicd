# Allows a token to manage its own lifecycle only.
module "self_token_admin_policy" {
  source = "../modules/acl-policy"

  name   = "self-token-admin"
  policy = file("${path.module}/../policies/github-self-token-admin.hcl")
}

# Exactly what the namespace-admin Terraform requires: namespace management,
# ACL policy management, and JWT auth config/roles.
module "github_admin_policy" {
  source = "../modules/acl-policy"

  name   = "github-admin"
  policy = file("${path.module}/../policies/github-admin.hcl")
}

# jwt_github JWT auth backend in the admin namespace — admin role only.
module "jwt_github" {
  source = "../modules/jwt-auth"

  path              = var.vault_auth_mount_path
  description       = "GitHub Actions OIDC JWT auth"
  bound_issuer      = "https://token.actions.githubusercontent.com"
  default_lease_ttl = var.default_lease_ttl
  max_lease_ttl     = var.max_lease_ttl
  roles             = local.jwt_roles
}
