resource "azurerm_key_vault" "default" {
  name                = "${var.prefix}kv"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  tags                = var.tags

  sku_name = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  public_network_access_enabled = true
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = var.tenant_id
  object_id    = var.object_id

  key_permissions = [
    "Create", "Delete", "Get", "List", "Update",
    "Purge", "Recover", "Decrypt", "Encrypt",
    "Sign", "Verify", "WrapKey", "UnwrapKey",
    "GetRotationPolicy", "SetRotationPolicy",
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover",
  ]
}

resource "azurerm_key_vault_key" "rsa" {
  name         = "${var.prefix}-rsa-key"
  key_vault_id = azurerm_key_vault.default.id
  key_type     = "RSA"
  key_size     = 2048
  tags         = var.tags

  key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  expiration_date = "2027-01-01T00:00:00Z"

  depends_on = [azurerm_key_vault_access_policy.current_user]
}

resource "random_password" "app" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
}

resource "azurerm_key_vault_secret" "app_password" {
  name         = "${var.prefix}-app-password"
  value        = random_password.app.result
  key_vault_id = azurerm_key_vault.default.id
  tags         = var.tags

  expiration_date = "2027-01-01T00:00:00Z"

  depends_on = [azurerm_key_vault_access_policy.current_user]
}
