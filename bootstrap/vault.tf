resource "vault_namespace" "namespaces" {
  for_each = toset(var.vault_namespaces)

  path = each.key
}
