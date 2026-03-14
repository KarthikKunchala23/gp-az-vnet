resource "azurerm_resource_group" "rg-name" {
  name     = "gp-az-vnet-rg"
  location = "centralIndia"
}

resource "azurerm_network_security_group" "gp-sg" {
  name                = "gp-security-group"
  location            = azurerm_resource_group.rg-name.location
  resource_group_name = azurerm_resource_group.rg-name.name
}

resource "azurerm_virtual_network" "gp-vnet" {
  name                = "gp-vnet-centralindia"
  location            = azurerm_resource_group.rg-name.location
  resource_group_name = azurerm_resource_group.rg-name.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name             = "gp-public-subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet {
    name             = "gp-private-subnet2"
    address_prefixes = ["10.0.2.0/24"]
    security_group   = azurerm_network_security_group.gp-sg.id
  }

  tags = {
    environment = "Development"
  }
}