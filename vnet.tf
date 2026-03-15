resource "azurerm_resource_group" "rg-name" {
  name     = "gp-az-vnet-rg"
  location = "centralIndia"
}

resource "azurerm_network_security_group" "gp-sg" {
  name                = "gp-security-group"
  location            = azurerm_resource_group.rg-name.location
  resource_group_name = azurerm_resource_group.rg-name.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "192.168.1.17/32"
    destination_address_prefix = "*"
  }

  tags = {
     "Name" = "gp-security-group" 
     environment = "Development"
  }
}

resource "azurerm_virtual_network" "gp-vnet" {
  location            = azurerm_resource_group.rg-name.location
  resource_group_name = azurerm_resource_group.rg-name.name
  count               = length(var.vnet_address_space)
  address_space       = var.vnet_address_space[count.index]
  name                = "gp-vnet-centralindia-${count.index + 1}"

  tags = {
    environment = "Development"
  }
}

resource "azurerm_subnet" "public_subnet" {
  count                = length(var.vnet_public_subnet_prefixes)
  name                 = "public-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg-name.name
  virtual_network_name = azurerm_virtual_network.gp-vnet[count.index].name
  address_prefixes     = var.vnet_public_subnet_prefixes[count.index]
}

resource "azurerm_subnet" "private_subnet" {
  count                = length(var.vnet_private_subnet_prefixes)
  name                 = "private-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg-name.name
  virtual_network_name = azurerm_virtual_network.gp-vnet[count.index].name
  address_prefixes     = var.vnet_private_subnet_prefixes[count.index]
}