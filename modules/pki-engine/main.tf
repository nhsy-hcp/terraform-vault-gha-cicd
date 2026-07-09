resource "vault_mount" "this" {
  path                  = var.path
  type                  = "pki"
  description           = var.description
  max_lease_ttl_seconds = var.max_lease_ttl
}

resource "vault_pki_secret_backend_root_cert" "this" {
  backend     = vault_mount.this.path
  type        = "internal"
  common_name = var.common_name
  ttl         = var.ttl
  key_type    = var.key_type
  key_bits    = var.key_bits
}

resource "vault_pki_secret_backend_role" "this" {
  for_each = var.roles

  backend          = vault_mount.this.path
  name             = each.key
  allowed_domains  = each.value.allowed_domains
  allow_subdomains = each.value.allow_subdomains
  max_ttl          = each.value.max_ttl
}
