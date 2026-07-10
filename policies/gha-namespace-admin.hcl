# gha-namespace-admin
#
# Universal, reusable ACL policy granting the broad capabilities a namespace admin
# needs (auth backends, identity, policies, mounts, quotas). It contains NO
# namespace-name references: it is created INSIDE each child namespace via a
# namespace-scoped vault provider alias, so namespace isolation enforces the
# boundary. A token operating in admin/tn001 cannot reach admin/tn002 even with
# identical policy paths.

path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/policies/acl" {
  capabilities = ["list"]
}

path "sys/namespaces/*" {
  capabilities = ["read", "update", "delete"]
}

path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "identity" {
  capabilities = ["list"]
}

path "auth/jwt" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "auth/jwt/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "auth/oidc" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "auth/oidc/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/auth" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/mounts/auth" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/mounts/auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/quotas/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/mounts" {
  capabilities = ["read", "list"]
}

path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/mounts/pki-int" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/remount" {
  capabilities = ["update", "sudo"]
}

path "sys/remount/*" {
  capabilities = ["read", "list"]
}
