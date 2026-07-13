variable "allowed_domains" {
  description = "List of domains for which certificates can be requested."
  type        = list(string)
  default     = []
}

variable "allow_subdomains" {
  description = "Whether to allow subdomains of allowed_domains."
  type        = bool
  default     = false
}

variable "backend" {
  description = "Mount path of the PKI secrets engine this role belongs to."
  type        = string
}

variable "generate_lease" {
  description = "Whether to generate a Vault lease for issued certificates."
  type        = bool
  default     = false
}

variable "key_bits" {
  description = "Number of bits for the generated key (e.g. 2048, 4096 for RSA; 256 for EC)."
  type        = number
  default     = 256
}

variable "key_type" {
  description = "Key algorithm for issued certificates: rsa, ec, or any."
  type        = string
  default     = "ec"
}

variable "issuer_ref" {
  description = "Reference to the named issuer to use for this role. Defaults to the mount's default issuer."
  type        = string
  default     = "default"
}

variable "max_ttl" {
  description = "Maximum TTL for certificates issued by this role (e.g. 168h)."
  type        = string
  default     = "168h"
}

variable "ttl" {
  description = "Default TTL for certificates issued by this role when not specified at request time (e.g. 24h). Must be <= max_ttl."
  type        = string
  default     = "24h"
}

variable "name" {
  description = "Name of the PKI role."
  type        = string
}

variable "no_store" {
  description = "Whether to not store certificates in the Vault storage backend."
  type        = bool
  default     = false
}
