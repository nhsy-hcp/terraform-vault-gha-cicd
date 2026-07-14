resource "vault_mount" "default" {
  path        = var.path
  type        = "kv-v2"
  description = var.description

  options = {
    version = "2"
  }
}

resource "vault_kv_secret_backend_v2" "config" {
  mount                = vault_mount.default.path
  max_versions         = var.max_versions
  cas_required         = var.cas_required
  delete_version_after = var.delete_version_after
}
