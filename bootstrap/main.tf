terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.112"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.78"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.10"
    }
  }
  required_version = ">= 1.9, < 2.0"
}

provider "hcp" {
  project_id = var.project_id
}

provider "vault" {
  address   = hcp_vault_cluster.vault_cluster.vault_public_endpoint_url
  token     = hcp_vault_cluster_admin_token.admin_token.token
  namespace = "admin"
}

provider "tfe" {
  organization = var.organization
  # token supplied via TFE_TOKEN / credentials.tfrc.json — never hardcoded
}

resource "random_pet" "default" {
  length = 1
}

resource "hcp_hvn" "vault_hvn" {
  hvn_id         = var.hvn_id
  cloud_provider = var.cloud_provider
  region         = var.region
  cidr_block     = var.hvn_cidr_block
}

resource "hcp_vault_cluster" "vault_cluster" {
  cluster_id      = "${var.cluster_id}-${random_pet.default.id}"
  hvn_id          = hcp_hvn.vault_hvn.hvn_id
  tier            = var.vault_tier
  public_endpoint = var.public_endpoint
}

resource "hcp_vault_cluster_admin_token" "admin_token" {
  cluster_id = hcp_vault_cluster.vault_cluster.cluster_id
}
