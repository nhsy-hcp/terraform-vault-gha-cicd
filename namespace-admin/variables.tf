variable "vault_token" {
  description = "The Vault token used to authenticate against the admin namespace"
  type        = string
  sensitive   = true
}
