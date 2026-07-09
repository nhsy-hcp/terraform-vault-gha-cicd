terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.78"
    }
  }
}
