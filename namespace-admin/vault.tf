module "namespace" {
  source   = "../modules/namespace"
  for_each = toset(var.vault_namespaces)

  name                  = each.key
  vault_auth_mount_path = var.vault_auth_mount_path
  github_organization   = var.github_organization
  github_repository     = var.github_repository
  default_lease_ttl     = var.default_lease_ttl
  max_lease_ttl         = var.max_lease_ttl
}
