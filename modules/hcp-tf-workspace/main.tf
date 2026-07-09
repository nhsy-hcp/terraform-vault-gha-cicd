resource "tfe_workspace" "this" {
  name              = var.name
  organization      = var.organization
  project_id        = var.project_id != "" ? var.project_id : null
  terraform_version = var.terraform_version
  tag_names         = var.tags
}

# Remote-state-only: Terraform runs happen in GitHub Actions, not in HCP
# Terraform. execution_mode = "local" uses the workspace purely to store and
# lock state. Managed via tfe_workspace_settings (the non-deprecated path).
resource "tfe_workspace_settings" "this" {
  workspace_id   = tfe_workspace.this.id
  execution_mode = "local"
}
