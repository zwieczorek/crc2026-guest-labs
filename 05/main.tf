resource "azurerm_storage_account" "default" {
  name                = "${local.prefix}satf"
  resource_group_name = data.azurerm_resource_group.default.name
  location            = data.azurerm_resource_group.default.location
  tags                = local.tags

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  min_tls_version           = "TLS1_2"
  shared_access_key_enabled = true

  public_network_access_enabled = true
  local_user_enabled            = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

}

resource "azurerm_storage_container" "default" {
  name                  = "terraform"
  storage_account_id    = azurerm_storage_account.default.id
  container_access_type = "private"
}
