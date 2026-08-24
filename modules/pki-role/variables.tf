variable "backend" {
  description = "Mount path of the PKI secrets engine this role belongs to."
  type        = string
}

variable "name" {
  description = "Name of the PKI role."
  type        = string
}

variable "issuer_ref" {
  description = "Reference to the named issuer to use for this role. Defaults to the mount's default issuer."
  type        = string
  default     = "default"
}

variable "ttl" {
  description = "Default TTL in seconds for certificates issued by this role. Must be <= max_ttl."
  type        = string
  default     = "86400"
}

variable "max_ttl" {
  description = "Maximum TTL in seconds for certificates issued by this role."
  type        = string
  default     = "604800"
}

variable "allow_localhost" {
  description = "Flag to allow certificates for localhost."
  type        = bool
  default     = false
}

variable "allowed_domains" {
  description = "List of domains for which certificates can be requested."
  type        = list(string)
  default     = []
}

variable "allow_bare_domains" {
  description = "Whether to allow the bare domains specified in allowed_domains."
  type        = bool
  default     = false
}

variable "allow_subdomains" {
  description = "Whether to allow subdomains of allowed_domains."
  type        = bool
  default     = false
}

variable "enforce_hostnames" {
  description = "Flag to allow only valid host names."
  type        = bool
  default     = true
}

variable "allow_ip_sans" {
  description = "Flag to allow IP SANs."
  type        = bool
  default     = false
}

variable "allowed_uri_sans" {
  description = "Defines allowed URI SANs."
  type        = list(string)
  default     = []
}

variable "allowed_other_sans" {
  description = "Defines allowed custom SANs."
  type        = list(string)
  default     = []
}

variable "allow_wildcard_certificates" {
  description = "Flag to allow wildcard certificates."
  type        = bool
  default     = false
}

variable "server_flag" {
  description = "Flag to specify certificates for server use."
  type        = bool
  default     = true
}

variable "cn_validations" {
  description = "Validations to run on the CN field: email, hostname, disabled."
  type        = list(string)
  default     = ["hostname"]
}

variable "key_type" {
  description = "Key algorithm for issued certificates: rsa, ec, ed25519, or any."
  type        = string
  default     = "ec"
}

variable "key_bits" {
  description = "Number of bits for the generated key (e.g. 2048, 4096 for RSA; 256 for EC)."
  type        = number
  default     = 256
}

variable "signature_bits" {
  description = "Number of bits to use in the signature algorithm."
  type        = number
  default     = null
}

variable "key_usage" {
  description = "Allowed key usage constraints on issued certificates."
  type        = list(string)
  default     = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
}

variable "ext_key_usage" {
  description = "Allowed extended key usage constraints on issued certificates."
  type        = list(string)
  default     = []
}

variable "ext_key_usage_oids" {
  description = "Allowed extended key usage OIDs on issued certificates."
  type        = list(string)
  default     = []
}

variable "use_csr_common_name" {
  description = "Flag to use the CN in the CSR."
  type        = bool
  default     = true
}

variable "use_csr_sans" {
  description = "Flag to use the SANs in the CSR."
  type        = bool
  default     = true
}

variable "ou" {
  description = "The organizational unit of generated certificates."
  type        = list(string)
  default     = []
}

variable "organization" {
  description = "The organization of generated certificates."
  type        = list(string)
  default     = []
}

variable "country" {
  description = "The country of generated certificates."
  type        = list(string)
  default     = []
}

variable "locality" {
  description = "The locality of generated certificates."
  type        = list(string)
  default     = []
}

variable "province" {
  description = "The province of generated certificates."
  type        = list(string)
  default     = []
}

variable "street_address" {
  description = "The street address of generated certificates."
  type        = list(string)
  default     = []
}

variable "postal_code" {
  description = "The postal code of generated certificates."
  type        = list(string)
  default     = []
}

variable "generate_lease" {
  description = "Whether to generate a Vault lease for issued certificates."
  type        = bool
  default     = false
}

variable "no_store" {
  description = "Whether to not store certificates in the Vault storage backend."
  type        = bool
  default     = false
}

variable "require_cn" {
  description = "Flag to force CN usage."
  type        = bool
  default     = true
}

variable "policy_identifier" {
  description = "List of policy identifier blocks (Vault 1.11+). Each object requires oid and optionally notice and cps."
  type = list(object({
    oid    = string
    notice = optional(string)
    cps    = optional(string)
  }))
  default = []
}



variable "allowed_serial_numbers" {
  description = "Array of allowed serial numbers to put in Subject."
  type        = list(string)
  default     = []
}


