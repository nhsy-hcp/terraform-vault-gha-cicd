locals {
  bound_repository = "${var.github_organization}/${var.github_repository}"

  # Default GitHub OIDC token audience used by hashicorp/vault-action (unless
  # overridden via jwtGithubAudience) — must match bound_audiences on every role.
  bound_audiences = ["https://github.com/${var.github_organization}"]

  # Admin-scoped role: identifies the caller by repository and is used by the
  # namespace-admin Terraform itself to manage auth, roles, and policies.
  admin_role = {
    "github-admin" = {
      user_claim      = "repository"
      bound_audiences = local.bound_audiences
      bound_claims = {
        repository = local.bound_repository
      }
      token_policies = ["self-token-admin", "github-admin"]
    }
  }

  # One role per tenant namespace, bound to both repository and workflow so only
  # the specific workflow file for that namespace can assume the role.
  namespace_roles = {
    for ns in var.vault_namespaces : "github-namespace-${ns}" => {
      user_claim        = "job_workflow_ref"
      bound_audiences   = local.bound_audiences
      bound_claims_type = "glob"
      bound_claims = {
        repository       = local.bound_repository
        job_workflow_ref = "${local.bound_repository}/.github/workflows/namespace-${ns}.yml@*"
      }
      token_policies = ["self-token-admin", "gha-namespace-admin"]
    }
  }

  jwt_roles = merge(local.admin_role, local.namespace_roles)
}
