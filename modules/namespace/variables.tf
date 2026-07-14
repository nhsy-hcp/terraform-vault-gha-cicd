variable "name" {
  description = "Child namespace path to create under the current provider namespace."
  type        = string
}

variable "vault_auth_mount_path" {
  description = "Mount path for the GitHub OIDC JWT auth backend inside the namespace."
  type        = string
  default     = "jwt_github"
}

variable "github_organization" {
  description = "GitHub organization that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository bound to the JWT auth role."
  type        = string
}

variable "default_lease_ttl" {
  description = "Default lease TTL for tokens issued by the JWT auth backend."
  type        = string
  default     = "1h"
}

variable "max_lease_ttl" {
  description = "Maximum lease TTL for tokens issued by the JWT auth backend."
  type        = string
  default     = "4h"
}
