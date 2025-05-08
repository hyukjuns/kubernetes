terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "hyukjuntfstatebackend"
    container_name       = "tfbackend"
    key                 = "aks.terraform.tfstate"
    
  }

  required_version = ">= 1.0.0"
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks" {
  name     = "rg-tf-aks"
  location = "koreacentral"
}

resource "azurerm_virtual_network" "aks" {
  name                = "tf-aks-vnet"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["192.168.0.0/16"]

  subnet {
    name             = "sn-aks"
    address_prefixes = ["192.168.0.0/23"]
  }
}

module "aks" {
  source                  = "../mod-aks"
  resource_group_name     = azurerm_resource_group.aks.name
  resource_group_location = azurerm_resource_group.aks.location
  cluster_name            = "tf-aks-cluster-001"
  subnet_id               = azurerm_virtual_network.aks.subnet.*.id[0]
  acr_name                = "tfaksacr"
  k8s_version             = "1.30.9"
  identity_role_scope     = azurerm_resource_group.aks.id
}
