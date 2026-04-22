module "network" {
  count = 2

  source = "./modules/network"

  prefix  = "name_${count.index}"
  rg_name = local.rg_name
}


resource "azurerm_virtual_network" "three" {
  name                = "my-network"
  location            = module.network[0].location
  resource_group_name = local.rg_name
  address_space       = ["10.0.0.0/16"]
}
