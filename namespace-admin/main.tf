terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.10"
    }
  }

  cloud {
    organization = "nhsy-hcp-org"

    workspaces {
      name = "namespace-admin"
    }
  }
}

provider "vault" {
  address   = var.vault_addr
  token     = var.vault_token
  namespace = "admin"
}
