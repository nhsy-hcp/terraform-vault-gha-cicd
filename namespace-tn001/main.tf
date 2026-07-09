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
      name = "namespace-tn001"
    }
  }
}

provider "vault" {
  address   = var.vault_addr
  token     = var.vault_token
  namespace = "admin/tn001"
}

# Day-2 configuration for the admin/tn001 tenant namespace.
#
# This module is a stub: the gha-namespace-admin policy is provisioned inside
# admin/tn001 by namespace-admin/. Add tenant secret engines here using the
# reusable modules in ../modules, e.g.:
#
# module "kv" {
#   source = "../modules/kv-engine"
#   path   = "kv"
# }
