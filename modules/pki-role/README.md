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
| <a name="input_allow_ip_sans"></a> [allow\_ip\_sans](#input\_allow\_ip\_sans) | Flag to allow IP SANs. | `bool` | `false` | no |
| <a name="input_allow_localhost"></a> [allow\_localhost](#input\_allow\_localhost) | Flag to allow certificates for localhost. | `bool` | `false` | no |
| <a name="input_allow_subdomains"></a> [allow\_subdomains](#input\_allow\_subdomains) | Whether to allow subdomains of allowed\_domains. | `bool` | `false` | no |
| <a name="input_allow_wildcard_certificates"></a> [allow\_wildcard\_certificates](#input\_allow\_wildcard\_certificates) | Flag to allow wildcard certificates. | `bool` | `false` | no |
| <a name="input_allowed_domains"></a> [allowed\_domains](#input\_allowed\_domains) | List of domains for which certificates can be requested. | `list(string)` | `[]` | no |
| <a name="input_allowed_other_sans"></a> [allowed\_other\_sans](#input\_allowed\_other\_sans) | Defines allowed custom SANs. | `list(string)` | `[]` | no |
| <a name="input_allowed_serial_numbers"></a> [allowed\_serial\_numbers](#input\_allowed\_serial\_numbers) | Array of allowed serial numbers to put in Subject. | `list(string)` | `[]` | no |
| <a name="input_allowed_uri_sans"></a> [allowed\_uri\_sans](#input\_allowed\_uri\_sans) | Defines allowed URI SANs. | `list(string)` | `[]` | no |
| <a name="input_backend"></a> [backend](#input\_backend) | Mount path of the PKI secrets engine this role belongs to. | `string` | n/a | yes |
| <a name="input_cn_validations"></a> [cn\_validations](#input\_cn\_validations) | Validations to run on the CN field: email, hostname, disabled. | `list(string)` | <pre>[<br/>  "hostname"<br/>]</pre> | no |
| <a name="input_enforce_hostnames"></a> [enforce\_hostnames](#input\_enforce\_hostnames) | Flag to allow only valid host names. | `bool` | `true` | no |
| <a name="input_ext_key_usage"></a> [ext\_key\_usage](#input\_ext\_key\_usage) | Allowed extended key usage constraints on issued certificates. | `list(string)` | `[]` | no |
| <a name="input_ext_key_usage_oids"></a> [ext\_key\_usage\_oids](#input\_ext\_key\_usage\_oids) | Allowed extended key usage OIDs on issued certificates. | `list(string)` | `[]` | no |
| <a name="input_generate_lease"></a> [generate\_lease](#input\_generate\_lease) | Whether to generate a Vault lease for issued certificates. | `bool` | `false` | no |
| <a name="input_issuer_ref"></a> [issuer\_ref](#input\_issuer\_ref) | Reference to the named issuer to use for this role. Defaults to the mount's default issuer. | `string` | `"default"` | no |
| <a name="input_key_bits"></a> [key\_bits](#input\_key\_bits) | Number of bits for the generated key (e.g. 2048, 4096 for RSA; 256 for EC). | `number` | `256` | no |
| <a name="input_key_type"></a> [key\_type](#input\_key\_type) | Key algorithm for issued certificates: rsa, ec, ed25519, or any. | `string` | `"ec"` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | Allowed key usage constraints on issued certificates. | `list(string)` | <pre>[<br/>  "DigitalSignature",<br/>  "KeyAgreement",<br/>  "KeyEncipherment"<br/>]</pre> | no |
| <a name="input_max_ttl"></a> [max\_ttl](#input\_max\_ttl) | Maximum TTL in seconds for certificates issued by this role. | `string` | `"604800"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the PKI role. | `string` | n/a | yes |
| <a name="input_no_store"></a> [no\_store](#input\_no\_store) | Whether to not store certificates in the Vault storage backend. | `bool` | `false` | no |
| <a name="input_policy_identifier"></a> [policy\_identifier](#input\_policy\_identifier) | List of policy identifier blocks (Vault 1.11+). Each object requires oid and optionally notice and cps. | <pre>list(object({<br/>    oid    = string<br/>    notice = optional(string)<br/>    cps    = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_require_cn"></a> [require\_cn](#input\_require\_cn) | Flag to force CN usage. | `bool` | `true` | no |
| <a name="input_server_flag"></a> [server\_flag](#input\_server\_flag) | Flag to specify certificates for server use. | `bool` | `true` | no |
| <a name="input_signature_bits"></a> [signature\_bits](#input\_signature\_bits) | Number of bits to use in the signature algorithm. | `number` | `null` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Default TTL in seconds for certificates issued by this role. Must be <= max\_ttl. | `string` | `"86400"` | no |
| <a name="input_use_csr_common_name"></a> [use\_csr\_common\_name](#input\_use\_csr\_common\_name) | Flag to use the CN in the CSR. | `bool` | `true` | no |
| <a name="input_use_csr_sans"></a> [use\_csr\_sans](#input\_use\_csr\_sans) | Flag to use the SANs in the CSR. | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_backend"></a> [backend](#output\_backend) | Mount path of the PKI secrets engine this role belongs to. |
| <a name="output_name"></a> [name](#output\_name) | Name of the PKI role. |
<!-- END_TF_DOCS -->