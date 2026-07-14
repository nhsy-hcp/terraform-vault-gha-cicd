<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [tfe_workspace.default](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace) | resource |
| [tfe_workspace_settings.default](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_settings) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Name of the HCP Terraform workspace. | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | Name of the HCP Terraform organization that owns the workspace. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the HCP Terraform project to assign to the workspace. Leave empty to use the organization default. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names to assign to the workspace. | `list(string)` | `[]` | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Terraform version configured for the workspace. | `string` | `"1.15.8"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | ID of the HCP Terraform workspace. |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | Name of the HCP Terraform workspace. |
<!-- END_TF_DOCS -->