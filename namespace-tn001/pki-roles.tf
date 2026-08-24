locals {
  cert_role_files = fileset("${path.module}/requests/certificates", "*.yaml")
  cert_roles = {
    for f in local.cert_role_files :
    trimsuffix(f, ".yaml") => yamldecode(
      file("${path.module}/requests/certificates/${f}")
    )
  }
}

module "cert_request_roles" {
  source   = "../modules/pki-role"
  for_each = local.cert_roles

  backend    = module.pki_intermediate.path
  name       = each.key
  issuer_ref = try(each.value.issuer_ref, "default")

  ttl     = try(each.value.ttl, "86400")
  max_ttl = try(each.value.max_ttl, "604800")

  allow_localhost    = try(each.value.allow_localhost, false)
  allowed_domains    = each.value.allowed_domains
  allow_bare_domains = try(each.value.allow_bare_domains, false)
  allow_subdomains   = try(each.value.allow_subdomains, false)
  enforce_hostnames  = try(each.value.enforce_hostnames, true)

  allow_ip_sans               = try(each.value.allow_ip_sans, false)
  allowed_uri_sans            = try(each.value.allowed_uri_sans, [])
  allowed_other_sans          = try(each.value.allowed_other_sans, [])
  allow_wildcard_certificates = try(each.value.allow_wildcard_certificates, false)

  server_flag    = try(each.value.server_flag, true)
  cn_validations = try(each.value.cn_validations, ["hostname"])

  key_type       = try(each.value.key_type, "ec")
  key_bits       = try(each.value.key_bits, 256)
  signature_bits = try(each.value.signature_bits, null)

  key_usage          = try(each.value.key_usage, ["DigitalSignature", "KeyAgreement", "KeyEncipherment"])
  ext_key_usage      = try(each.value.ext_key_usage, [])
  ext_key_usage_oids = try(each.value.ext_key_usage_oids, [])

  use_csr_common_name = try(each.value.use_csr_common_name, true)
  use_csr_sans        = try(each.value.use_csr_sans, true)

  ou             = try(each.value.ou, [])
  organization   = try(each.value.organization, [])
  country        = try(each.value.country, [])
  locality       = try(each.value.locality, [])
  province       = try(each.value.province, [])
  street_address = try(each.value.street_address, [])
  postal_code    = try(each.value.postal_code, [])

  generate_lease = try(each.value.generate_lease, false)
  no_store       = try(each.value.no_store, false)
  require_cn     = try(each.value.require_cn, true)

  policy_identifier = try(each.value.policy_identifier, [])

  allowed_serial_numbers = try(each.value.allowed_serial_numbers, [])
}
