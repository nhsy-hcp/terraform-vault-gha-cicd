# Day-2 configuration for the admin namespace.
#
# This module is a stub: the jwt_github auth backend, its roles, and the
# self-token-admin / github-admin / gha-namespace-admin policies are
# provisioned by bootstrap/ (applied locally before any CI workflow can run,
# avoiding a chicken-and-egg dependency on Vault auth existing).
#
# Add day-2 secret engines scoped to the admin namespace here using the
# reusable modules in ../modules, e.g.:
#
# module "kv" {
#   source = "../modules/kv-engine"
#   path   = "kv"
# }
