# github-admin
#
# Exactly what the namespace-admin Terraform requires: namespace management,
# ACL policy management, and JWT auth config/roles. Bound to the github-admin
# JWT auth role (repository-scoped, used by the namespace-admin workflow).

path "sys/namespaces" {
  capabilities = ["list"]
}

path "sys/namespaces/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/policies/acl" {
  capabilities = ["list"]
}

path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/jwt/config" {
  capabilities = ["create", "read", "update", "delete"]
}

path "auth/jwt/role" {
  capabilities = ["list"]
}

path "auth/jwt/role/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
