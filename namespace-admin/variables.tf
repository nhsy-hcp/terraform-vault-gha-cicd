variable "vault_namespaces" {
  description = "List of child namespace paths to create under admin"
  type        = list(string)
  default     = []
}

variable "vault_auth_mount_path" {
  description = "Mount path for the GitHub OIDC JWT auth method"
  type        = string
  default     = "jwt_github"
}

variable "github_organization" {
  description = "GitHub organization that owns the repository"
  type        = string
  default     = "nhsy-hcp"
}

variable "github_repository" {
  description = "GitHub repository bound to the JWT auth roles"
  type        = string
  default     = "terraform-vault-gha-cicd"
}

variable "default_lease_ttl" {
  description = "Default lease TTL for tokens issued by the JWT auth method"
  type        = string
  default     = "1h"
}

variable "max_lease_ttl" {
  description = "Maximum lease TTL for tokens issued by the JWT auth method"
  type        = string
  default     = "4h"
}
