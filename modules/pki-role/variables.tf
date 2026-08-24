variable "backend" {
  description = "Mount path of the PKI secrets engine this role belongs to."
  type        = string
  validation {
    condition     = length(var.backend) > 0
    error_message = "backend must not be empty."
  }
}

variable "name" {
  description = "Name of the PKI role."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.name))
    error_message = "name must be lowercase alphanumeric with hyphens, and must start and end with an alphanumeric character."
  }
}

variable "issuer_ref" {
  description = "Reference to the named issuer to use for this role. Defaults to the mount's default issuer."
  type        = string
  default     = "default"
  validation {
    condition     = length(var.issuer_ref) > 0
    error_message = "issuer_ref must not be empty."
  }
}

variable "ttl" {
  description = "Default TTL in seconds for certificates issued by this role. Must be <= max_ttl."
  type        = string
  default     = "86400"
  validation {
    condition     = can(regex("^[0-9]+$", var.ttl))
    error_message = "ttl must be a numeric string representing seconds (e.g. \"86400\")."
  }
}

variable "max_ttl" {
  description = "Maximum TTL in seconds for certificates issued by this role."
  type        = string
  default     = "604800"
  validation {
    condition     = can(regex("^[0-9]+$", var.max_ttl))
    error_message = "max_ttl must be a numeric string representing seconds (e.g. \"604800\")."
  }
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
  validation {
    condition     = length(var.allowed_domains) > 0
    error_message = "allowed_domains must contain at least one domain."
  }
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
  validation {
    condition = alltrue([
      for v in var.cn_validations : contains(["email", "hostname", "disabled"], v)
    ])
    error_message = "cn_validations entries must be one of: email, hostname, disabled."
  }
}

variable "key_type" {
  description = "Key algorithm for issued certificates: rsa, ec, ed25519, or any."
  type        = string
  default     = "ec"
  validation {
    condition     = contains(["rsa", "ec", "ed25519", "any"], var.key_type)
    error_message = "key_type must be one of: rsa, ec, ed25519, any."
  }
}

variable "key_bits" {
  description = "Number of bits for the generated key (e.g. 2048, 4096 for RSA; 256 for EC)."
  type        = number
  default     = 256
  validation {
    condition     = contains([0, 224, 256, 384, 521, 2048, 3072, 4096, 8192], var.key_bits)
    error_message = "key_bits must be 0 (auto), a valid EC size (224, 256, 384, 521), or a valid RSA size (2048, 3072, 4096, 8192)."
  }
}

variable "signature_bits" {
  description = "Number of bits to use in the signature algorithm."
  type        = number
  default     = null
  validation {
    condition     = var.signature_bits == null || contains([256, 384, 512], var.signature_bits)
    error_message = "signature_bits must be null or one of: 256, 384, 512."
  }
}

variable "key_usage" {
  description = "Allowed key usage constraints on issued certificates."
  type        = list(string)
  default     = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
  validation {
    condition = alltrue([
      for v in var.key_usage : contains([
        "DigitalSignature", "ContentCommitment", "KeyEncipherment",
        "DataEncipherment", "KeyAgreement", "CertSign", "CRLSign",
        "EncipherOnly", "DecipherOnly"
      ], v)
    ])
    error_message = "key_usage entries must be valid X.509 key usage values."
  }
}

variable "ext_key_usage" {
  description = "Allowed extended key usage constraints on issued certificates."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for v in var.ext_key_usage : contains([
        "ServerAuth", "ClientAuth", "CodeSigning", "EmailProtection",
        "IPSECEndSystem", "IPSECTunnel", "IPSECUser", "TimeStamping",
        "OCSPSigning", "MicrosoftServerGatedCrypto", "NetscapeServerGatedCrypto"
      ], v)
    ])
    error_message = "ext_key_usage entries must be valid extended key usage values."
  }
}

variable "ext_key_usage_oids" {
  description = "Allowed extended key usage OIDs on issued certificates."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for v in var.ext_key_usage_oids : can(regex("^[0-9]+(\\.[0-9]+)+$", v))
    ])
    error_message = "ext_key_usage_oids entries must be valid OID strings (e.g. \"1.3.6.1.5.5.7.3.1\")."
  }
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
  validation {
    condition = alltrue([
      for p in var.policy_identifier : can(regex("^[0-9]+(\\.[0-9]+)+$", p.oid))
    ])
    error_message = "Each policy_identifier oid must be a valid OID string (e.g. \"2.5.29.32.0\")."
  }
}

variable "allowed_serial_numbers" {
  description = "Array of allowed serial numbers to put in Subject."
  type        = list(string)
  default     = []
}
