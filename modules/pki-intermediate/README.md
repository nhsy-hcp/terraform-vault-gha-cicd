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
| [vault_mount.default](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount) | resource |
| [vault_pki_secret_backend_config_cluster.default](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_cluster) | resource |
| [vault_pki_secret_backend_config_urls.default](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_urls) | resource |
| [vault_pki_secret_backend_crl_config.default](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_crl_config) | resource |
| [vault_pki_secret_backend_intermediate_cert_request.default](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_intermediate_cert_request) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_aia_path"></a> [cluster\_aia\_path](#input\_cluster\_aia\_path) | Vault cluster AIA path for AIA URL templating. Defaults to cluster\_path if empty. | `string` | `""` | no |
| <a name="input_cluster_path"></a> [cluster\_path](#input\_cluster\_path) | Vault cluster API path for AIA URL templating (e.g. https://vault.example.com:8200/v1/admin/tn001/pki-int). Required when enable\_templating=true. | `string` | `""` | no |
| <a name="input_common_name"></a> [common\_name](#input\_common\_name) | Common name for the intermediate CA certificate. | `string` | n/a | yes |
| <a name="input_crl_disable"></a> [crl\_disable](#input\_crl\_disable) | Disable CRL building entirely. Not recommended for production. | `bool` | `false` | no |
| <a name="input_crl_distribution_points"></a> [crl\_distribution\_points](#input\_crl\_distribution\_points) | List of URLs to be used as CRL distribution points in issued certificates. | `list(string)` | `[]` | no |
| <a name="input_crl_expiry"></a> [crl\_expiry](#input\_crl\_expiry) | Specifies the time until expiration of the CRL (e.g. 72h). | `string` | `"72h"` | no |
| <a name="input_default_lease_ttl"></a> [default\_lease\_ttl](#input\_default\_lease\_ttl) | Default lease TTL for the intermediate PKI mount in seconds (default 30 days). | `number` | `2592000` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the intermediate PKI secrets engine mount. | `string` | `"PKI intermediate secrets engine"` | no |
| <a name="input_enable_templating"></a> [enable\_templating](#input\_enable\_templating) | Allow AIA URL templating (e.g. {{cluster\_path}}, {{issuer\_id}}). | `bool` | `false` | no |
| <a name="input_issuing_certificates"></a> [issuing\_certificates](#input\_issuing\_certificates) | List of URLs to be used as the issuing certificate endpoints. | `list(string)` | `[]` | no |
| <a name="input_key_bits"></a> [key\_bits](#input\_key\_bits) | Number of bits for the intermediate CA private key. | `number` | `256` | no |
| <a name="input_key_type"></a> [key\_type](#input\_key\_type) | Key type for the intermediate CA private key. | `string` | `"ec"` | no |
| <a name="input_max_lease_ttl"></a> [max\_lease\_ttl](#input\_max\_lease\_ttl) | Maximum lease TTL for the intermediate PKI mount in seconds (default 1 year). | `number` | `31536000` | no |
| <a name="input_ocsp_enable"></a> [ocsp\_enable](#input\_ocsp\_enable) | Enable OCSP responder on this PKI mount. | `bool` | `true` | no |
| <a name="input_ocsp_expiry"></a> [ocsp\_expiry](#input\_ocsp\_expiry) | The amount of time an OCSP response will be valid (e.g. 12h). | `string` | `"12h"` | no |
| <a name="input_ocsp_servers"></a> [ocsp\_servers](#input\_ocsp\_servers) | List of URLs to be used as OCSP server endpoints in issued certificates. | `list(string)` | `[]` | no |
| <a name="input_path"></a> [path](#input\_path) | Mount path for the intermediate PKI secrets engine. | `string` | `"pki-int"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_accessor"></a> [accessor](#output\_accessor) | Accessor for the intermediate PKI secrets engine mount. |
| <a name="output_csr"></a> [csr](#output\_csr) | PEM-encoded CSR for the intermediate CA, to be signed offline by the root CA. |
| <a name="output_path"></a> [path](#output\_path) | Mount path of the intermediate PKI secrets engine. |
<!-- END_TF_DOCS -->