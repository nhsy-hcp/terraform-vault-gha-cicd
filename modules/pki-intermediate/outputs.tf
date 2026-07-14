output "accessor" {
  description = "Accessor for the intermediate PKI secrets engine mount."
  value       = try(vault_mount.default.accessor, null)
}

output "csr" {
  description = "PEM-encoded CSR for the intermediate CA, to be signed offline by the root CA."
  value       = try(vault_pki_secret_backend_intermediate_cert_request.default.csr, null)
}

output "path" {
  description = "Mount path of the intermediate PKI secrets engine."
  value       = try(vault_mount.default.path, null)
}
