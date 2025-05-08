<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [azurerm_container_registry.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) (resource)
- [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) (resource)
- [azurerm_role_assignment.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.aks_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_acr_name"></a> [acr\_name](#input\_acr\_name)

Description: ACR 이름

Type: `string`

### <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)

Description: 클러스터 이름

Type: `string`

### <a name="input_identity_role_scope"></a> [identity\_role\_scope](#input\_identity\_role\_scope)

Description: AKS Identity의 권한 할당 범위 - AKS 하위 리소스 컨트롤을 위함

Type: `string`

### <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version)

Description: 쿠버네티스 버전 지정

Type: `string`

### <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location)

Description: AKS가 배포될 리소스 그룹의 Azure 지역

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: AKS가 배포뵐 리소스 그룹 이름

Type: `string`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: AKS가 사용할 Subnet ID

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_aks_id"></a> [aks\_id](#output\_aks\_id)

Description: n/a

### <a name="output_aks_identity"></a> [aks\_identity](#output\_aks\_identity)

Description: n/a

### <a name="output_aks_key_vault_secrets_provider"></a> [aks\_key\_vault\_secrets\_provider](#output\_aks\_key\_vault\_secrets\_provider)

Description: n/a

### <a name="output_aks_name"></a> [aks\_name](#output\_aks\_name)

Description: n/a

### <a name="output_aks_network_profile"></a> [aks\_network\_profile](#output\_aks\_network\_profile)

Description: n/a

### <a name="output_aks_node_resource_group"></a> [aks\_node\_resource\_group](#output\_aks\_node\_resource\_group)

Description: n/a

### <a name="output_aks_node_resource_group_id"></a> [aks\_node\_resource\_group\_id](#output\_aks\_node\_resource\_group\_id)

Description: n/a

### <a name="output_aks_oidc_issuer_url"></a> [aks\_oidc\_issuer\_url](#output\_aks\_oidc\_issuer\_url)

Description: n/a

### <a name="output_aks_oms_agent"></a> [aks\_oms\_agent](#output\_aks\_oms\_agent)

Description: n/a

### <a name="output_aks_portal_fqdn"></a> [aks\_portal\_fqdn](#output\_aks\_portal\_fqdn)

Description: n/a
<!-- END_TF_DOCS -->