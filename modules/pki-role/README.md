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
| [vault_pki_secret_backend_role.default](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allow_bare_domains"></a> [allow\_bare\_domains](#input\_allow\_bare\_domains) | Whether to allow the bare domains specified in allowed\_domains. | `bool` | `false` | no |
| <a name="input_allow_subdomains"></a> [allow\_subdomains](#input\_allow\_subdomains) | Whether to allow subdomains of allowed\_domains. | `bool` | `false` | no |
| <a name="input_allowed_domains"></a> [allowed\_domains](#input\_allowed\_domains) | List of domains for which certificates can be requested. | `list(string)` | `[]` | no |
| <a name="input_backend"></a> [backend](#input\_backend) | Mount path of the PKI secrets engine this role belongs to. | `string` | n/a | yes |
| <a name="input_generate_lease"></a> [generate\_lease](#input\_generate\_lease) | Whether to generate a Vault lease for issued certificates. | `bool` | `false` | no |
| <a name="input_issuer_ref"></a> [issuer\_ref](#input\_issuer\_ref) | Reference to the named issuer to use for this role. Defaults to the mount's default issuer. | `string` | `"default"` | no |
| <a name="input_key_bits"></a> [key\_bits](#input\_key\_bits) | Number of bits for the generated key (e.g. 2048, 4096 for RSA; 256 for EC). | `number` | `256` | no |
| <a name="input_key_type"></a> [key\_type](#input\_key\_type) | Key algorithm for issued certificates: rsa, ec, or any. | `string` | `"ec"` | no |
| <a name="input_max_ttl"></a> [max\_ttl](#input\_max\_ttl) | Maximum TTL for certificates issued by this role (e.g. 168h). | `string` | `"168h"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the PKI role. | `string` | n/a | yes |
| <a name="input_no_store"></a> [no\_store](#input\_no\_store) | Whether to not store certificates in the Vault storage backend. | `bool` | `false` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Default TTL for certificates issued by this role when not specified at request time (e.g. 24h). Must be <= max\_ttl. | `string` | `"24h"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_backend"></a> [backend](#output\_backend) | Mount path of the PKI secrets engine this role belongs to. |
| <a name="output_name"></a> [name](#output\_name) | Name of the PKI role. |
<!-- END_TF_DOCS -->