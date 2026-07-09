variable "vault_addr" {
  description = "The address of the HCP Vault cluster public endpoint"
  type        = string
}

variable "vault_token" {
  description = "The Vault token used to authenticate against the admin/tn001 namespace"
  type        = string
  sensitive   = true
}
