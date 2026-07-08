output "hvn_id" {
  description = "The ID of the HashiCorp Virtual Network"
  value       = hcp_hvn.vault_hvn.hvn_id
}

output "hvn_cidr_block" {
  description = "The CIDR block of the HashiCorp Virtual Network"
  value       = hcp_hvn.vault_hvn.cidr_block
}

output "hvn_provider_account_id" {
  description = "The provider account ID where the HVN is located"
  value       = hcp_hvn.vault_hvn.provider_account_id
}

output "vault_cluster_id" {
  description = "The ID of the HCP Vault cluster"
  value       = hcp_vault_cluster.vault_cluster.cluster_id
}

output "vault_private_endpoint_url" {
  description = "The private endpoint URL of the Vault cluster"
  value       = hcp_vault_cluster.vault_cluster.vault_private_endpoint_url
}

output "vault_public_endpoint_url" {
  description = "The public endpoint URL of the Vault cluster"
  value       = hcp_vault_cluster.vault_cluster.vault_public_endpoint_url
}

output "vault_version" {
  description = "The version of Vault running on the cluster"
  value       = hcp_vault_cluster.vault_cluster.vault_version
}

output "vault_namespace" {
  description = "The namespace of the Vault cluster"
  value       = hcp_vault_cluster.vault_cluster.namespace
}

output "vault_admin_token" {
  description = "The admin token for the Vault cluster"
  value       = hcp_vault_cluster_admin_token.admin_token.token
  sensitive   = true
}

output "vault_cluster_state" {
  description = "The state of the Vault cluster"
  value       = hcp_vault_cluster.vault_cluster.state
}

output "vault_tier" {
  description = "The tier of the Vault cluster"
  value       = hcp_vault_cluster.vault_cluster.tier
}

output "cloud_provider" {
  description = "The cloud provider where the cluster is deployed"
  value       = hcp_vault_cluster.vault_cluster.cloud_provider
}

output "region" {
  description = "The region where the cluster is deployed"
  value       = hcp_vault_cluster.vault_cluster.region
}

output "vault_env_exports" {
  description = "Export commands for VAULT_ADDR and VAULT_TOKEN"
  value       = <<-EOT
    export VAULT_ADDR=${hcp_vault_cluster.vault_cluster.vault_public_endpoint_url}
    export VAULT_TOKEN=${hcp_vault_cluster_admin_token.admin_token.token}
  EOT
  sensitive   = true
}

output "vault_env_eval" {
  description = "Command to eval vault environment exports"
  value       = "eval \"$(task bootstrap:env)\""
}
