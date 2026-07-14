output "accessor" {
  description = "Accessor for the JWT auth backend."
  value       = vault_jwt_auth_backend.default.accessor
}

output "path" {
  description = "Path of the JWT auth backend."
  value       = vault_jwt_auth_backend.default.path
}

output "role_names" {
  description = "Names of the JWT auth backend roles."
  value       = keys(vault_jwt_auth_backend_role.default)
}
