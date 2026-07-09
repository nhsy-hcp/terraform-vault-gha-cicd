locals {
  bound_repository = "${var.github_organization}/${var.github_repository}"

  # Admin-scoped role: identifies the caller by repository and is used by the
  # namespace-admin Terraform itself to manage auth, roles, and policies.
  admin_role = {
    "github-admin" = {
      user_claim = "repository"
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
      user_claim = "workflow"
      bound_claims = {
        repository = local.bound_repository
        workflow   = "namespace-${ns}"
      }
      token_policies = ["self-token-admin", "gha-namespace-admin"]
    }
  }

  jwt_roles = merge(local.admin_role, local.namespace_roles)
}

# Allows a token to manage its own lifecycle only.
module "self_token_admin_policy" {
  source = "../modules/acl-policy"

  name   = "self-token-admin"
  policy = <<-EOT
    path "auth/token/lookup-self" {
      capabilities = ["read"]
    }

    path "auth/token/renew-self" {
      capabilities = ["update"]
    }

    path "auth/token/revoke-self" {
      capabilities = ["update"]
    }
  EOT
}

# Exactly what the namespace-admin Terraform requires: namespace management,
# ACL policy management, and JWT auth config/roles.
module "github_admin_policy" {
  source = "../modules/acl-policy"

  name   = "github-admin"
  policy = <<-EOT
    path "sys/namespaces" {
      capabilities = ["list"]
    }

    path "sys/namespaces/*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }

    path "sys/policies/acl" {
      capabilities = ["list"]
    }

    path "sys/policies/acl/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }

    path "auth/jwt/config" {
      capabilities = ["create", "read", "update", "delete"]
    }

    path "auth/jwt/role" {
      capabilities = ["list"]
    }

    path "auth/jwt/role/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }
  EOT
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
# The provider-level namespace argument scopes each policy to admin/<name>, so
# namespace isolation enforces the boundary with no cross-namespace path refs.
resource "vault_policy" "gha_namespace_admin" {
  for_each = toset(var.vault_namespaces)

  namespace = "admin/${each.key}"
  name      = "gha-namespace-admin"
  policy    = file("${path.module}/../policies/gha-namespace-admin.hcl")
}
