resource "azurerm_virtual_network" "default" {
  name                = "${var.prefix}-network"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}
