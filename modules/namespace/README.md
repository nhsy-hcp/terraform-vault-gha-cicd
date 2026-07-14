<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_vault"></a> [vault](#provider\_vault) | n/a |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_jwt_github"></a> [jwt\_github](#module\_jwt\_github) | ../jwt-auth | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [vault_namespace.default](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/namespace) | resource |
| [vault_policy.gha_namespace_admin](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.self_token_admin](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_default_lease_ttl"></a> [default\_lease\_ttl](#input\_default\_lease\_ttl) | Default lease TTL for tokens issued by the JWT auth backend. | `string` | `"1h"` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | GitHub organization that owns the repository. | `string` | n/a | yes |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | GitHub repository bound to the JWT auth role. | `string` | n/a | yes |
| <a name="input_max_lease_ttl"></a> [max\_lease\_ttl](#input\_max\_lease\_ttl) | Maximum lease TTL for tokens issued by the JWT auth backend. | `string` | `"4h"` | no |
| <a name="input_name"></a> [name](#input\_name) | Child namespace path to create under the current provider namespace. | `string` | n/a | yes |
| <a name="input_vault_auth_mount_path"></a> [vault\_auth\_mount\_path](#input\_vault\_auth\_mount\_path) | Mount path for the GitHub OIDC JWT auth backend inside the namespace. | `string` | `"jwt_github"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_jwt_auth_backend_path"></a> [jwt\_auth\_backend\_path](#output\_jwt\_auth\_backend\_path) | Mount path of the JWT auth backend inside the namespace. |
| <a name="output_jwt_role_name"></a> [jwt\_role\_name](#output\_jwt\_role\_name) | Name of the JWT auth role created inside the namespace. |
| <a name="output_path"></a> [path](#output\_path) | Path of the created Vault namespace. |
| <a name="output_path_fq"></a> [path\_fq](#output\_path\_fq) | Fully-qualified path of the created Vault namespace. |
<!-- END_TF_DOCS -->