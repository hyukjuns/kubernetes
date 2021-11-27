terraform {
  # 특정 Version 고정, Terraform Version과 Provider 버전을 따로 관리
  required_version = "0.13.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.40.0"
    }
  }
}
provider "azurerm" {
  features {}
}