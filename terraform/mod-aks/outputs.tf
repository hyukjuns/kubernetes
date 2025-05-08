output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}
output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
output "aks_portal_fqdn" {
  value = azurerm_kubernetes_cluster.aks.portal_fqdn
}
output "aks_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}
output "aks_node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}
output "aks_node_resource_group_id" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group_id
}
output "aks_network_profile" {
  value = azurerm_kubernetes_cluster.aks.network_profile
}
output "aks_oms_agent" {
  value = azurerm_kubernetes_cluster.aks.oms_agent
}
output "aks_key_vault_secrets_provider" {
  value = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider
}
output "aks_identity" {
  value = azurerm_kubernetes_cluster.aks.identity
}