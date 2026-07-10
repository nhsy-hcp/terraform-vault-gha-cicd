# self-token-admin
#
# Allows a token to manage its own lifecycle only (lookup, renew, revoke).
# Attached to every JWT auth role so callers can inspect/renew/revoke the
# token issued to them without needing broader token management rights.

path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}
