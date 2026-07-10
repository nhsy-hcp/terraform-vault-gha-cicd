resource "vault_jwt_auth_backend" "this" {
  path               = var.path
  description        = var.description
  oidc_discovery_url = var.oidc_discovery_url
  bound_issuer       = var.bound_issuer != "" ? var.bound_issuer : null
  default_role       = null

  tune {
    default_lease_ttl = var.default_lease_ttl
    max_lease_ttl     = var.max_lease_ttl
  }
}

resource "vault_jwt_auth_backend_role" "this" {
  for_each = var.roles

  backend         = vault_jwt_auth_backend.this.path
  role_name       = each.key
  role_type       = each.value.role_type
  user_claim      = each.value.user_claim
  bound_claims    = each.value.bound_claims
  bound_audiences = each.value.bound_audiences
  token_policies  = each.value.token_policies
  token_ttl       = each.value.token_ttl
  token_max_ttl   = each.value.token_max_ttl
}
