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

  cluster_path            = var.vault_address != "" ? "${var.vault_address}/v1/admin/tn001/pki-int" : ""
  enable_templating       = true
  issuing_certificates    = ["{{cluster_path}}/issuer/{{issuer_id}}/der"]
  crl_distribution_points = ["{{cluster_path}}/issuer/{{issuer_id}}/crl/der"]
  ocsp_servers            = ["{{cluster_path}}/ocsp"]
}

