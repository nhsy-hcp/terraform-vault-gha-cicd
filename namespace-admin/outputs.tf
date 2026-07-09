output "vault_jwt_auth_backend_path" {
  description = "Mount path of the jwt_github auth backend"
  value       = module.jwt_github.path
}

output "vault_github_admin_role" {
  description = "Name of the admin-scoped JWT auth role"
  value       = "github-admin"
}

output "vault_github_namespace_roles" {
  description = "Map of child namespace to its per-namespace JWT auth role name"
  value       = { for ns in var.vault_namespaces : ns => "github-namespace-${ns}" }
}
