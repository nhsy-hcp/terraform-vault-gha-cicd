output "vault_namespaces" {
  description = "Created Vault child namespace paths."
  value       = [for ns in module.namespace : ns.path]
}

output "vault_github_namespace_roles" {
  description = "Map of child namespace to its per-namespace JWT auth role name."
  value       = { for k, ns in module.namespace : k => ns.jwt_role_name }
}
