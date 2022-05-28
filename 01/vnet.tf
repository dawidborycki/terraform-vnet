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

resource "azurerm_virtual_network" "single-vnet" {
  name                = "single-vnet"
  location            = azurerm_resource_group.rg-terraform-vnet.location
  resource_group_name = azurerm_resource_group.rg-terraform-vnet.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet-backends"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet-frontends"
    address_prefix = "10.0.2.0/24"
  }

  tags = {
    Pattern = "Single Virtual Network"
  }
}