resource "tfe_project" "main" {
  name         = var.project_name
  organization = var.organization
}

resource "tfe_team" "gha_cicd" {
  name         = "${var.project_name}-gha-cicd"
  organization = var.organization
}

resource "tfe_team_project_access" "gha_cicd" {
  access     = "admin"
  team_id    = tfe_team.gha_cicd.id
  project_id = tfe_project.main.id
}

resource "tfe_team_token" "gha_cicd" {
  team_id = tfe_team.gha_cicd.id
}

module "namespace_workspace" {
  source   = "../modules/hcp-tf-workspace"
  for_each = toset(var.namespaces)

  name         = each.value
  organization = var.organization
  project_id   = tfe_project.main.id
}
