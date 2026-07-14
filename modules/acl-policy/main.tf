resource "vault_policy" "default" {
  name   = var.name
  policy = var.policy
}
