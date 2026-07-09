resource "vault_mount" "this" {
  path        = var.path
  type        = "kv-v2"
  description = var.description

  options = {
    version = "2"
  }
}
