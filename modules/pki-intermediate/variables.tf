variable "common_name" {
  description = "Common name for the intermediate CA certificate."
  type        = string
}

variable "crl_disable" {
  description = "Disable CRL building entirely. Not recommended for production."
  type        = bool
  default     = false
}

variable "crl_distribution_points" {
  description = "List of URLs to be used as CRL distribution points in issued certificates."
  type        = list(string)
  default     = []
}

variable "crl_expiry" {
  description = "Specifies the time until expiration of the CRL (e.g. 72h)."
  type        = string
  default     = "72h"
}

variable "description" {
  description = "Description for the intermediate PKI secrets engine mount."
  type        = string
  default     = "PKI intermediate secrets engine"
}

variable "issuing_certificates" {
  description = "List of URLs to be used as the issuing certificate endpoints."
  type        = list(string)
  default     = []
}

variable "key_bits" {
  description = "Number of bits for the intermediate CA private key."
  type        = number
  default     = 256
}

variable "key_type" {
  description = "Key type for the intermediate CA private key."
  type        = string
  default     = "ec"
}

variable "default_lease_ttl" {
  description = "Default lease TTL for the intermediate PKI mount in seconds (default 30 days)."
  type        = number
  default     = 2592000
}

variable "max_lease_ttl" {
  description = "Maximum lease TTL for the intermediate PKI mount in seconds (default 1 year)."
  type        = number
  default     = 31536000
}

variable "ocsp_enable" {
  description = "Enable OCSP responder on this PKI mount."
  type        = bool
  default     = true
}

variable "ocsp_expiry" {
  description = "The amount of time an OCSP response will be valid (e.g. 12h)."
  type        = string
  default     = "12h"
}

variable "enable_templating" {
  description = "Allow AIA URL templating (e.g. {{cluster_path}}, {{issuer_id}})."
  type        = bool
  default     = false
}

variable "ocsp_servers" {
  description = "List of URLs to be used as OCSP server endpoints in issued certificates."
  type        = list(string)
  default     = []
}

variable "path" {
  description = "Mount path for the intermediate PKI secrets engine."
  type        = string
  default     = "pki-int"
}

variable "cluster_path" {
  description = "Vault cluster API path for AIA URL templating (e.g. https://vault.example.com:8200/v1/admin/tn001/pki-int). Required when enable_templating=true."
  type        = string
  default     = ""
}

variable "cluster_aia_path" {
  description = "Vault cluster AIA path for AIA URL templating. Defaults to cluster_path if empty."
  type        = string
  default     = ""
}
