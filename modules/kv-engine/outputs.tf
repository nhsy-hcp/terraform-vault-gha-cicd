output "accessor" {
  description = "Accessor for the KV v2 secrets engine mount."
  value       = vault_mount.this.accessor
}

output "path" {
  description = "Path of the KV v2 secrets engine mount."
  value       = vault_mount.this.path
}
