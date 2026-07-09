output "namespace_id" {
  description = "ID of the created Vault namespace."
  value       = vault_namespace.this.namespace_id
}

output "path" {
  description = "Path of the created Vault namespace."
  value       = vault_namespace.this.path
}
