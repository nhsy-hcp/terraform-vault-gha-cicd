variable "pki_roles" {
  description = "Map of PKI roles to create under the tn001 intermediate CA."
  type = map(object({
    allowed_domains    = list(string)
    allow_bare_domains = optional(bool, false)
    allow_subdomains   = optional(bool, false)
    ttl                = optional(string, "24h")
    max_ttl            = optional(string, "168h")
    generate_lease     = optional(bool, false)
    no_store           = optional(bool, false)
    key_type           = optional(string, "ec")
    key_bits           = optional(number, 256)
    issuer_ref         = optional(string, "default")
  }))
  default = {}
}
