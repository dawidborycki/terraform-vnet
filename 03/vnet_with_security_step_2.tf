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

resource "azurerm_virtual_network" "vnet-with-security" {
  name                = "vnet-with-security"
  resource_group_name = azurerm_resource_group.rg-terraform-vnet.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-terraform-vnet.location   
}

resource "azurerm_subnet" "subnet-frontends" {
  name                 = "subnet-frontends"
  resource_group_name  = azurerm_resource_group.rg-terraform-vnet.name
  virtual_network_name = azurerm_virtual_network.vnet-with-security.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "security-group-1" {
  name                = "security-group-1"
  location            = azurerm_resource_group.rg-terraform-vnet.location
  resource_group_name = azurerm_resource_group.rg-terraform-vnet.name

  security_rule {
    name                       = "allow-on-80"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "security-group-to-subnet-association" {
  subnet_id                 = azurerm_subnet.subnet-frontends.id
  network_security_group_id = azurerm_network_security_group.security-group-1.id
}

resource "azurerm_route_table" "route-table-1" {
  name                = "route-table-1"
  location            = azurerm_resource_group.rg-terraform-vnet.location
  resource_group_name = azurerm_resource_group.rg-terraform-vnet.name

  route {
    name                   = "route-1"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}

resource "azurerm_subnet_route_table_association" "route-table-to-subnet-association" {
  subnet_id      = azurerm_subnet.subnet-frontends.id
  route_table_id = azurerm_route_table.route-table-1.id
}