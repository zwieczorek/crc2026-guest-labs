
resource "azurerm_storage_account" "default" {
  name                     = "${var.prefix}linuxfunctionappsa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "default" {
  name                = "${var.prefix}-app-service-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_function_app" "default" {
  name                = "${var.prefix}-linux-function-app"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.default.name
  storage_account_access_key = azurerm_storage_account.default.primary_access_key
  service_plan_id            = azurerm_service_plan.default.id

  site_config {}
}
