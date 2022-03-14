resource "azurerm_resource_group" "terraform_rg" {
  name     = "terraform-rg"
  location = "koreacentral"
}
module "network" {
  source              = "Azure/network/azurerm"
  version             = "3.2.1"
  vnet_name           = "aks-vnet"
  resource_group_name = azurerm_resource_group.terraform_rg.name
  address_space       = "10.0.0.0/8"
  subnet_prefixes     = ["10.240.0.0/16", "10.1.0.0/16"]
  subnet_names        = ["aksSubnet00", "subnet01"]
  depends_on          = [azurerm_resource_group.terraform_rg]
}
data "azurerm_subnet" "aks_subnet" {
  name                 = "aksSubnet00"
  virtual_network_name = "aks-vnet"
  resource_group_name  = azurerm_resource_group.terraform_rg.name
  depends_on           = [module.network]
}
resource "azurerm_kubernetes_cluster" "hyukjun_cluster" {
  # Basics
  name                = "hyukjun-cluster"
  location            = azurerm_resource_group.terraform_rg.location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  kubernetes_version  = "1.19.3"

  # Node pools
  default_node_pool {
    name       = "hjagentpool"
    node_count = 3
    vm_size    = "Standard_DS2_v2"
    # For Azure CNI Network Plugin
    vnet_subnet_id = data.azurerm_subnet.aks_subnet.id
    # availability_zones
    # koreacentral not supported
    # Cluster AutoScaler
    # enable_auto_scaling = true
    # max_count = 10
    # min_count = 3
    # max_pods
    # node_labels
    # type = "AvailabilitySet" (Defaults to VirtualMachineScaleSets)
  }

  # Authentication
  identity {
    # Authentication method(Service principal, System-assigned managed identity)
    type = "SystemAssigned" # At this time the only supported value is SystemAssigned
  }
  role_based_access_control {
    enabled = true
  }

  # Networking
  network_profile {
    network_plugin     = "azure" # Azure CNI
    service_cidr       = "10.0.0.0/16"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip     = "10.0.0.10"
  }
  dns_prefix = "hyukjun-cluster-dns"
  # private_cluster_enabled

  # Integrations
  #   addon_profile{
  #     aci_connector_linux
  #     azure_policy
  #     oms_agent
  #     kube_dashboard
  #   }

  # Tags
  tags = {
    Environment = "Test"
  }
}
