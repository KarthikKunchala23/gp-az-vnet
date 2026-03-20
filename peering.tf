# enable global peering between the two virtual network
resource "azurerm_virtual_network_peering" "peering" {
  count                        = length(var.vnet_address_space)
  name                         = "peering-to-${element(azurerm_virtual_network.gp-vnet.*.name, 1 - count.index)}"
  resource_group_name          = element(azurerm_resource_group.rg-name.*.name, count.index)
  virtual_network_name         = element(azurerm_virtual_network.gp-vnet.*.name, count.index)
  remote_virtual_network_id    = element(azurerm_virtual_network.gp-vnet.*.id, 1 - count.index)
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit = false
}