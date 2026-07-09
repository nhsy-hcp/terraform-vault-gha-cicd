resource "vault_pki_secret_backend_role" "this" {
  backend          = var.backend
  name             = var.name
  allowed_domains  = var.allowed_domains
  allow_subdomains = var.allow_subdomains
  max_ttl          = var.max_ttl
  generate_lease   = var.generate_lease
  no_store         = var.no_store
  key_type         = var.key_type
  key_bits         = var.key_bits
}
