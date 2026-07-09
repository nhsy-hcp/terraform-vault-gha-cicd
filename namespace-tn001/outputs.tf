output "pki_intermediate_csr" {
  description = "PEM-encoded CSR for the tn001 intermediate CA, to be signed offline by the root CA."
  value       = module.pki_intermediate.csr
}
