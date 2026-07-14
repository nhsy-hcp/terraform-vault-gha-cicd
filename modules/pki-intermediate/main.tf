resource "vault_mount" "default" {
  path                      = var.path
  type                      = "pki"
  description               = var.description
  default_lease_ttl_seconds = var.default_lease_ttl
  max_lease_ttl_seconds     = var.max_lease_ttl
}

resource "vault_pki_secret_backend_intermediate_cert_request" "default" {
  backend     = vault_mount.default.path
  type        = "internal"
  common_name = var.common_name
  key_type    = var.key_type
  key_bits    = var.key_bits
}

resource "vault_pki_secret_backend_config_urls" "default" {
  count   = length(var.issuing_certificates) > 0 || length(var.crl_distribution_points) > 0 || length(var.ocsp_servers) > 0 ? 1 : 0
  backend = vault_mount.default.path

  issuing_certificates    = var.issuing_certificates
  crl_distribution_points = var.crl_distribution_points
  ocsp_servers            = var.ocsp_servers
  enable_templating       = var.enable_templating

  depends_on = [vault_pki_secret_backend_intermediate_cert_request.default]
}

resource "vault_pki_secret_backend_crl_config" "default" {
  backend = vault_mount.default.path

  expiry  = var.crl_expiry
  disable = var.crl_disable

  ocsp_disable = !var.ocsp_enable
  ocsp_expiry  = var.ocsp_expiry

  depends_on = [vault_pki_secret_backend_intermediate_cert_request.default]
}
