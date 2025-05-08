resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  # k8s version
  kubernetes_version        = var.k8s_version

  # Basic
  dns_prefix = "terraform"

  default_node_pool {
    name                = "default"
    type                = "VirtualMachineScaleSets"
    zones               = [1, 2, 3]
    node_count          = 3
    vm_size             = "Standard_D2as_v4"
    vnet_subnet_id      = var.subnet_id
  }
  
  # AutoScale 된 Node Count는 LifeCycle로 관리
  lifecycle {
    ignore_changes = [  
      default_node_pool[0].upgrade_settings,
      monitor_metrics,
      oms_agent,
      default_node_pool[0].node_count ]
  }

  # Network
  network_profile {
    network_plugin    = "azure"
    network_mode      = "transparent"
    network_policy    = "calico"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"
    outbound_type     = "loadBalancer"
    load_balancer_sku = "standard"
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  # azure_policy_enabled = true
}

# ACR
resource "azurerm_container_registry" "aks" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_role_assignment" "aks" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.aks.id
  skip_service_principal_aad_check = true
}

# Assign Role AKS Identity to VNET
resource "azurerm_role_assignment" "aks_rg" {
  principal_id                     = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name             = "Network Contributor"
  scope                            = var.identity_role_scope
  skip_service_principal_aad_check = true
}