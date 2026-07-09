output "accessor" {
  description = "Accessor for the intermediate PKI secrets engine mount."
  value       = vault_mount.this.accessor
}

output "csr" {
  description = "PEM-encoded CSR for the intermediate CA, to be signed offline by the root CA."
  value       = vault_pki_secret_backend_intermediate_cert_request.this.csr
}

output "path" {
  description = "Mount path of the intermediate PKI secrets engine."
  value       = vault_mount.this.path
}
