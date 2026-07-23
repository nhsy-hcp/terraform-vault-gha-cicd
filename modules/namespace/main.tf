locals {
  bound_repository = "${var.github_organization}/${var.github_repository}"
  bound_audiences  = ["https://github.com/${var.github_organization}"]
}

resource "vault_namespace" "default" {
  path = var.name
}

resource "vault_policy" "self_token_admin" {
  namespace = vault_namespace.default.path
  name      = "self-token-admin"
  policy    = file("${path.module}/../../policies/github-self-token-admin.hcl")
}

resource "vault_policy" "gha_namespace_admin" {
  namespace = vault_namespace.default.path
  name      = "github-namespace-admin"
  policy    = file("${path.module}/../../policies/github-namespace-admin.hcl")
}

module "jwt_github" {
  source = "../jwt-auth"

  namespace         = vault_namespace.default.path
  path              = var.vault_auth_mount_path
  description       = "GitHub Actions OIDC JWT auth"
  bound_issuer      = "https://token.actions.githubusercontent.com"
  default_lease_ttl = var.default_lease_ttl
  max_lease_ttl     = var.max_lease_ttl
  roles = {
    "github-namespace-${var.name}" = {
      user_claim      = "workflow"
      bound_audiences = local.bound_audiences
      bound_claims = {
        repository = local.bound_repository
        workflow   = "namespace-${var.name}"
      }
      token_policies = ["self-token-admin", "github-namespace-admin"]
    }
  }

  depends_on = [vault_namespace.default]
}
