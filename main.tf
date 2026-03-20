resource "azurerm_public_ip" "gp_public_ip" {
  count = length(azurerm_subnet.public_subnet)
  name = "gp-public-ip-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg-name.name
  location = azurerm_resource_group.rg-name.location
  allocation_method = "Static"
  sku = "Standard"

  tags = { 
    environment = "Development"
   }
}

## Network Interface
resource "azurerm_network_interface" "gp_nic" {
  count               = length(azurerm_subnet.public_subnet)
  name                = "gp-nic-${count.index + 1}"
  location            = azurerm_resource_group.rg-name.location
  resource_group_name = azurerm_resource_group.rg-name.name

  ip_configuration {
    name                          = "gp-ip-config-${count.index + 1}"
    subnet_id                     = azurerm_subnet.public_subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gp_public_ip[count.index].id
  }

  tags = {
    environment = "Development"
  }
}

resource "azurerm_network_interface_security_group_association" "gp_nic_sg_assoc" {
  count = length(azurerm_network_interface.gp_nic)
  network_interface_id = azurerm_network_interface.gp_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.gp-sg.id
}

resource "azurerm_linux_virtual_machine" "gp-linux-vm" {
  count = length(azurerm_subnet.public_subnet)
  name = "gp-linux-vm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg-name.name
  location = azurerm_resource_group.rg-name.location
  disable_password_authentication = false
  size = "Standard_B1s"
  admin_username = "linuxadmin"
  admin_password = var.admin_password
  network_interface_ids = [azurerm_network_interface.gp_nic[count.index].id]
  computer_name = "linuxvm-${count.index + 1}"
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer = "0001-com-ubuntu-server-jammy"
    publisher = "Canonical"
    sku = "22_04-lts"
    version = "latest"
  }
}

## private vm in each vnet
resource "azurerm_network_interface" "gp_nic_private" {
  count               = length(azurerm_subnet.private_subnet)
  name                = "gp-nic-private-${count.index + 1}"
  location            = azurerm_resource_group.rg-name.location
  resource_group_name = azurerm_resource_group.rg-name.name

  ip_configuration {
    name                          = "gp-ip-config-private-${count.index + 1}"
    subnet_id                     = azurerm_subnet.private_subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "gp-linux-vm-private" {
  count = length(azurerm_subnet.private_subnet)
  name = "gp-linux-vm-private-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg-name.name
  location = azurerm_resource_group.rg-name.location
  disable_password_authentication = false
  size = "Standard_B1s"
  admin_username = "linuxadmin"
  admin_password = var.admin_password
  network_interface_ids = [azurerm_network_interface.gp_nic_private[count.index].id]
  computer_name = "linuxvm-private-${count.index + 1}"
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer = "0001-com-ubuntu-server-jammy"
    publisher = "Canonical"
    sku = "22_04-lts"
    version = "latest"
  }
}

resource "azurerm_network_security_group" "gp-sg-private" {
  count = length(azurerm_subnet.private_subnet)
  name                = "gp-sg-private-${count.index + 1}"
  location            = azurerm_resource_group.rg-name.location
  resource_group_name = azurerm_resource_group.rg-name.name

  security_rule {
    name                       = "gp-sg-rule-private-${count.index + 1}"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    protocol                   = "Tcp"
  }
}

resource "azurerm_network_interface_security_group_association" "gp_nic_sg_assoc_private" {
  count = length(azurerm_network_interface.gp_nic_private)
  network_interface_id = azurerm_network_interface.gp_nic_private[count.index].id
  network_security_group_id = azurerm_network_security_group.gp-sg-private[count.index].id
}
