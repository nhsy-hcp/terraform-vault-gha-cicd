output "accessor" {
  description = "Accessor for the PKI secrets engine mount."
  value       = vault_mount.this.accessor
}

output "issuing_ca" {
  description = "PEM-encoded issuing CA certificate generated for the PKI secrets engine."
  value       = vault_pki_secret_backend_root_cert.this.certificate
}

output "path" {
  description = "Path of the PKI secrets engine mount."
  value       = vault_mount.this.path
}
