variable "pki_roles" {
  description = "Map of PKI roles to create under the tn001 intermediate CA."
  type = map(object({
    allowed_domains  = list(string)
    allow_subdomains = optional(bool, false)
    max_ttl          = optional(string, "24h")
    generate_lease   = optional(bool, false)
    key_type         = optional(string, "ec")
    key_bits         = optional(number, 256)
  }))
}
