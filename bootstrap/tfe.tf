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

resource "time_rotating" "team_token" {
  rotation_days = 7
}

resource "tfe_team_token" "gha_cicd" {
  team_id    = tfe_team.gha_cicd.id
  expired_at = time_rotating.team_token.rotation_rfc3339
}

module "namespace_workspace" {
  source   = "../modules/hcp-tf-workspace"
  for_each = toset(var.namespaces)

  name         = each.value
  organization = var.organization
  project_id   = tfe_project.main.id
}
