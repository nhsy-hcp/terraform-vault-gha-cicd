resource "vault_pki_secret_backend_role" "default" {
  backend    = var.backend
  name       = var.name
  issuer_ref = var.issuer_ref

  ttl     = var.ttl
  max_ttl = var.max_ttl

  allow_localhost    = var.allow_localhost
  allowed_domains    = var.allowed_domains
  allow_bare_domains = var.allow_bare_domains
  allow_subdomains   = var.allow_subdomains
  enforce_hostnames  = var.enforce_hostnames

  allow_ip_sans               = var.allow_ip_sans
  allowed_uri_sans            = var.allowed_uri_sans
  allowed_other_sans          = var.allowed_other_sans
  allow_wildcard_certificates = var.allow_wildcard_certificates

  server_flag    = var.server_flag
  cn_validations = var.cn_validations

  key_type       = var.key_type
  key_bits       = var.key_bits
  signature_bits = var.signature_bits

  key_usage          = var.key_usage
  ext_key_usage      = var.ext_key_usage
  ext_key_usage_oids = var.ext_key_usage_oids

  use_csr_common_name = var.use_csr_common_name
  use_csr_sans        = var.use_csr_sans

  generate_lease = var.generate_lease
  no_store       = var.no_store
  require_cn     = var.require_cn

  dynamic "policy_identifier" {
    for_each = var.policy_identifier
    content {
      oid    = policy_identifier.value.oid
      notice = policy_identifier.value.notice
      cps    = policy_identifier.value.cps
    }
  }

  allowed_serial_numbers = var.allowed_serial_numbers
}
