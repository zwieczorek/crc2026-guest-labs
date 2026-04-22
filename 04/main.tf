module "network" {
  source = "./network"

  prefix              = "dev"
  resource_group_name = "rg-crc2026-student-XXX-lab"
  tags                = local.tags

}


resource "azurerm_network_interface" "default" {
  name                = "xx-nic"
  location            = module.network.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.one_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = module.network.public_ip
  }
}

resource "azurerm_linux_virtual_machine" "default" {
  name                = "xx-vm"
  resource_group_name = local.rg_name
  location            = module.network.location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.default.id,
  ]

  admin_password                  = var.password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

}

module "web" {
  source = "./web"

  prefix              = "dev"
  resource_group_name = local.rg_name
  tags                = local.tags
  location            = module.network.location
}
