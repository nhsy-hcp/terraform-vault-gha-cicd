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
| [vault_kv_secret_backend_v2.config](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_backend_v2) | resource |
| [vault_mount.default](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cas_required"></a> [cas\_required](#input\_cas\_required) | Whether check-and-set is required for writes to the KV v2 secrets engine. | `bool` | `false` | no |
| <a name="input_delete_version_after"></a> [delete\_version\_after](#input\_delete\_version\_after) | Number of seconds after which deleted KV v2 versions are permanently deleted. 0 disables automatic deletion. | `number` | `0` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the KV v2 secrets engine mount. | `string` | `"KV v2 secrets engine"` | no |
| <a name="input_max_versions"></a> [max\_versions](#input\_max\_versions) | Maximum number of versions retained for each KV v2 secret. | `number` | `10` | no |
| <a name="input_path"></a> [path](#input\_path) | Mount path for the KV v2 secrets engine. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_accessor"></a> [accessor](#output\_accessor) | Accessor for the KV v2 secrets engine mount. |
| <a name="output_path"></a> [path](#output\_path) | Path of the KV v2 secrets engine mount. |
<!-- END_TF_DOCS -->