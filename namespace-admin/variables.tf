variable "vault_addr" {
  description = "The address of the HCP Vault cluster public endpoint"
  type        = string
}

variable "vault_token" {
  description = "The Vault token used to authenticate against the admin namespace"
  type        = string
  sensitive   = true
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

variable "token_type" {
  description = "Token type issued by the JWT auth roles"
  type        = string
  default     = "default"
}

variable "vault_namespaces" {
  description = "Child namespaces (under admin) to provision per-namespace roles and policies for. Keep in sync with bootstrap/."
  type        = list(string)
  default     = ["tn001"]
}
