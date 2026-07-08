variable "project_id" {
  description = "The HCP project ID"
  type        = string
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
