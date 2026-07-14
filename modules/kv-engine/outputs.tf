output "accessor" {
  description = "Accessor for the KV v2 secrets engine mount."
  value       = vault_mount.default.accessor
}

output "path" {
  description = "Path of the KV v2 secrets engine mount."
  value       = vault_mount.default.path
}
