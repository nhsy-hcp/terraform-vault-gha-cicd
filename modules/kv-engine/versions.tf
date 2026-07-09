terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.10"
    }
  }
}
