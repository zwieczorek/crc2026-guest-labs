module "keyvault" {
  source = "./modules/keyvault"

  prefix              = local.prefix
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  tags                = local.tags
}

module "vm" {
  source = "./modules/vm"

  prefix              = local.prefix
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  admin_password      = module.keyvault.secret_value
  tags                = local.tags
}
