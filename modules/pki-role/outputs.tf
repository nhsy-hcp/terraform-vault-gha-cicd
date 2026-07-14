output "name" {
  description = "Name of the PKI role."
  value       = vault_pki_secret_backend_role.default.name
}

output "backend" {
  description = "Mount path of the PKI secrets engine this role belongs to."
  value       = vault_pki_secret_backend_role.default.backend
}
