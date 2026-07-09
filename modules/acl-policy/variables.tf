variable "name" {
  description = "Name of the Vault ACL policy."
  type        = string
}

variable "policy" {
  description = "HCL policy document for the Vault ACL policy."
  type        = string
}
