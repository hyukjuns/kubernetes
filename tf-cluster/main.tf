terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.81.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "aks" {
  name = "k8s"
}
resource "azurerm_virtual_network" "aks" {
  name                = "${var.prefix}-network"
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "aks" {
  name                 = "azurecni"
  virtual_network_name = azurerm_virtual_network.aks.name
  resource_group_name  = data.azurerm_resource_group.aks.name
  address_prefixes     = ["10.240.0.0/16"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks-01"
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name

  # k8s version
  kubernetes_version = "1.21.1"
  // automatic_channel_upgrade = "stable"

  # Basic
  dns_prefix     = "${var.prefix}aks01"
  default_node_pool {
    name                = "default"
    type                = "VirtualMachineScaleSets"
    availability_zones  = [1, 2, 3]
    node_count          = 3
    vm_size             = "Standard_D2_v2"
    vnet_subnet_id      = azurerm_subnet.aks.id
    enable_auto_scaling = true
    max_count           = 3
    min_count           = 1
  }
  lifecycle {
      ignore_changes = [default_node_pool[0].node_count]
  }

  # Network
  network_profile {
    network_plugin     = "azure"
    network_mode       = "transparent"
    network_policy     = "calico"
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    outbound_type      = "loadBalancer"
    load_balancer_sku  = "Standard"
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }
  role_based_access_control {
    enabled = true
  }

  # Integration
  addon_profile {
    aci_connector_linux {
      enabled = false
    }
    azure_policy {
      enabled = false
    }
    http_application_routing {
      enabled = false
    }
    kube_dashboard {
      enabled = false
    }
    oms_agent {
      enabled = false
    }
  }
}