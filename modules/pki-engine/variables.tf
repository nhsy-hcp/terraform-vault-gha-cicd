variable "common_name" {
  description = "Common name for the internal root CA certificate."
  type        = string
}

variable "description" {
  description = "Description for the PKI secrets engine mount."
  type        = string
  default     = "PKI secrets engine"
}

variable "key_bits" {
  description = "Number of bits for the generated root CA private key."
  type        = number
  default     = 2048
}

variable "key_type" {
  description = "Key type for the generated root CA private key."
  type        = string
  default     = "rsa"
}

variable "max_lease_ttl" {
  description = "Maximum lease TTL for the PKI secrets engine mount in seconds."
  type        = number
  default     = 31536000
}

variable "path" {
  description = "Mount path for the PKI secrets engine."
  type        = string
  default     = "pki"
}

variable "roles" {
  description = "Map of PKI roles keyed by role name."
  type = map(object({
    allowed_domains  = optional(list(string), [])
    allow_subdomains = optional(bool, true)
    max_ttl          = optional(string, "72h")
  }))
  default = {}
}

variable "ttl" {
  description = "TTL for the generated internal root CA certificate in seconds."
  type        = number
  default     = 31536000
}
