output "path" {
  description = "Path of the created Vault namespace."
  value       = vault_namespace.default.path
}

output "path_fq" {
  description = "Fully-qualified path of the created Vault namespace."
  value       = vault_namespace.default.path_fq
}

output "jwt_auth_backend_path" {
  description = "Mount path of the JWT auth backend inside the namespace."
  value       = module.jwt_github.path
}

output "jwt_role_name" {
  description = "Name of the JWT auth role created inside the namespace."
  value       = "github-namespace-${var.name}"
}
