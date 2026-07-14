variable "vault_address" {
  description = "Vault cluster public address used to build PKI AIA/cluster URLs (e.g. https://vault.example.com:8200). Set via TF_VAR_vault_address or VAULT_ADDR."
  type        = string
  default     = ""
}

variable "pki_roles" {
  description = "Map of PKI roles to create under the tn001 intermediate CA."
  type = map(object({
    allowed_domains    = list(string)
    allow_bare_domains = optional(bool, false)
    allow_subdomains   = optional(bool, false)
    ttl                = optional(string, "86400")
    max_ttl            = optional(string, "604800")
    generate_lease     = optional(bool, false)
    no_store           = optional(bool, false)
    key_type           = optional(string, "ec")
    key_bits           = optional(number, 256)
    issuer_ref         = optional(string, "default")
  }))
  default = {}
}
