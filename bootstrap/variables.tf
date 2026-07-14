variable "project_id" {
  description = "The HCP project ID"
  type        = string
}

variable "organization" {
  description = "HCP Terraform organization"
  type        = string
  default     = "nhsy-hcp-org"
}

variable "project_name" {
  description = "HCP Terraform project name (equals the repo name)"
  type        = string
  default     = "terraform-vault-gha-cicd"
}

variable "namespaces" {
  description = "Day-2 modules needing a remote-state workspace"
  type        = list(string)
  default     = ["namespace-admin", "namespace-tn001"]
}

variable "hvn_id" {
  description = "The ID of the HashiCorp Virtual Network (HVN)"
  type        = string
  default     = "vault-hvn"
}

variable "cluster_id" {
  description = "The ID of the HCP Vault cluster"
  type        = string
  default     = "vault-cluster"
}

variable "cloud_provider" {
  description = "The cloud provider where the HVN and Vault cluster will be created"
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws", "azure"], var.cloud_provider)
    error_message = "Cloud provider must be either 'aws' or 'azure'."
  }
}

variable "region" {
  description = "The region where the HVN and Vault cluster will be created"
  type        = string
  default     = "us-west-2"
}

variable "hvn_cidr_block" {
  description = "The CIDR block for the HVN"
  type        = string
  default     = "172.25.16.0/20"
}

variable "vault_tier" {
  description = "The tier of the HCP Vault cluster"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "starter_small", "standard_small", "standard_medium", "standard_large", "plus_small", "plus_medium", "plus_large"], var.vault_tier)
    error_message = "Vault tier must be one of: dev, starter_small, standard_small, standard_medium, standard_large, plus_small, plus_medium, plus_large."
  }
}

variable "public_endpoint" {
  description = "Whether the Vault cluster should have a public endpoint"
  type        = bool
  default     = true
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
