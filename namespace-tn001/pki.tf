# PKI intermediate CA for admin/tn001.
#
# Implements the offline-root CA pattern from:
# https://developer.hashicorp.com/vault/tutorials/pki/pki-engine-external-ca
#
# The root CA is managed offline with OpenSSL (see Taskfile pki:root:* tasks).
# Vault manages only the intermediate CA mounted at "pki-int".
#
# Workflow:
#   1. task pki:root:generate          — create offline root CA
#   2. terraform apply                 — create intermediate mount + generate CSR
#   3. task pki:int:csr                — retrieve CSR from Vault
#   4. task pki:int:sign               — sign CSR with offline root CA
#   5. task pki:int:import             — import signed cert into Vault

module "pki_intermediate" {
  source = "../modules/pki-intermediate"

  path        = "pki-int"
  description = "PKI intermediate CA for tn001"
  common_name = "tn001 Intermediate CA"
}

module "pki_roles" {
  source   = "../modules/pki-role"
  for_each = var.pki_roles

  backend          = module.pki_intermediate.path
  name             = each.key
  allowed_domains  = each.value.allowed_domains
  allow_subdomains = each.value.allow_subdomains
  max_ttl          = each.value.max_ttl
  generate_lease   = each.value.generate_lease
  key_type         = each.value.key_type
  key_bits         = each.value.key_bits
}
