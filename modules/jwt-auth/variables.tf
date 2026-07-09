variable "bound_issuer" {
  description = "Expected issuer claim for JWTs. Leave empty to omit issuer binding."
  type        = string
  default     = ""
}

variable "default_lease_ttl" {
  description = "Default lease TTL for the JWT auth backend."
  type        = string
  default     = "1h"
}

variable "description" {
  description = "Description for the JWT auth backend mount."
  type        = string
  default     = "JWT auth backend"
}

variable "max_lease_ttl" {
  description = "Maximum lease TTL for the JWT auth backend."
  type        = string
  default     = "4h"
}

variable "oidc_discovery_url" {
  description = "OIDC discovery URL used by the JWT auth backend."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "path" {
  description = "Mount path for the JWT auth backend."
  type        = string
  default     = "jwt_github"
}

variable "roles" {
  description = "Map of JWT auth backend roles keyed by role name."
  type = map(object({
    bound_audiences = optional(list(string))
    bound_claims    = map(string)
    role_type       = optional(string, "jwt")
    token_max_ttl   = optional(number)
    token_policies  = list(string)
    token_ttl       = optional(number)
    user_claim      = string
  }))
  default = {}
}
