output "workspace_id" {
  description = "ID of the HCP Terraform workspace."
  value       = tfe_workspace.default.id
}

output "workspace_name" {
  description = "Name of the HCP Terraform workspace."
  value       = tfe_workspace.default.name
}
