<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_vault"></a> [vault](#provider\_vault) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [vault_jwt_auth_backend.default](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend) | resource |
| [vault_jwt_auth_backend_role.default](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend_role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bound_issuer"></a> [bound\_issuer](#input\_bound\_issuer) | Expected issuer claim for JWTs. Leave empty to omit issuer binding. | `string` | `""` | no |
| <a name="input_default_lease_ttl"></a> [default\_lease\_ttl](#input\_default\_lease\_ttl) | Default lease TTL for the JWT auth backend. | `string` | `"1h"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the JWT auth backend mount. | `string` | `"JWT auth backend"` | no |
| <a name="input_max_lease_ttl"></a> [max\_lease\_ttl](#input\_max\_lease\_ttl) | Maximum lease TTL for the JWT auth backend. | `string` | `"4h"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Vault namespace to create the JWT auth backend in. Leave empty to use the provider default. | `string` | `""` | no |
| <a name="input_oidc_discovery_url"></a> [oidc\_discovery\_url](#input\_oidc\_discovery\_url) | OIDC discovery URL used by the JWT auth backend. | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_path"></a> [path](#input\_path) | Mount path for the JWT auth backend. | `string` | `"jwt_github"` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Map of JWT auth backend roles keyed by role name. | <pre>map(object({<br/>    bound_audiences = optional(list(string))<br/>    bound_claims    = map(string)<br/>    role_type       = optional(string, "jwt")<br/>    token_max_ttl   = optional(number)<br/>    token_policies  = list(string)<br/>    token_ttl       = optional(number)<br/>    user_claim      = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_accessor"></a> [accessor](#output\_accessor) | Accessor for the JWT auth backend. |
| <a name="output_path"></a> [path](#output\_path) | Path of the JWT auth backend. |
| <a name="output_role_names"></a> [role\_names](#output\_role\_names) | Names of the JWT auth backend roles. |
<!-- END_TF_DOCS -->