variable "vault_address" {
  description = "Vault cluster public address used to build PKI AIA/cluster URLs (e.g. https://vault.example.com:8200). Set via TF_VAR_vault_address or VAULT_ADDR."
  type        = string
  default     = ""
}

