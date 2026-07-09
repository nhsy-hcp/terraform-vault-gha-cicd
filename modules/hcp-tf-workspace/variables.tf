variable "name" {
  description = "Name of the HCP Terraform workspace."
  type        = string
}

variable "organization" {
  description = "Name of the HCP Terraform organization that owns the workspace."
  type        = string
}

variable "project_id" {
  description = "ID of the HCP Terraform project to assign to the workspace. Leave empty to use the organization default."
  type        = string
  default     = ""
}

variable "tags" {
  description = "List of tag names to assign to the workspace."
  type        = list(string)
  default     = []
}

variable "terraform_version" {
  description = "Terraform version configured for the workspace."
  type        = string
  default     = "1.15.8"
}
