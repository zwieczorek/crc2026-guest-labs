
resource "azurerm_virtual_network" "default" {
  name                = "vnet-name"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name
  address_space       = ["192.168.0.0/24"]


  tags = local.tags
}
