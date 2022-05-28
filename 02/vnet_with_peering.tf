terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-terraform-vnet" {
  name     = "rg-terraform-vnet"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet-1" {
  name                = "vnet-1"
  resource_group_name = azurerm_resource_group.rg-terraform-vnet.name
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.rg-terraform-vnet.location
}

resource "azurerm_virtual_network" "vnet-2" {
  name                = "vnet-2"
  resource_group_name = azurerm_resource_group.rg-terraform-vnet.name
  address_space       = ["10.0.2.0/24"]
  location            = azurerm_resource_group.rg-terraform-vnet.location
}

resource "azurerm_virtual_network_peering" "peer-vnet1-to-vnet2" {
  name                      = "peer-vnet1-to-vnet2"
  resource_group_name       = azurerm_resource_group.rg-terraform-vnet.name
  virtual_network_name      = azurerm_virtual_network.vnet-1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-2.id
}

resource "azurerm_virtual_network_peering" "peer-vnet2-to-vnet1" {
  name                      = "peer-vnet2-to-vnet1"
  resource_group_name       = azurerm_resource_group.rg-terraform-vnet.name
  virtual_network_name      = azurerm_virtual_network.vnet-2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-1.id
} 