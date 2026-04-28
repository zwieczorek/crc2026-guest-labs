output "secret_value" {
  value     = azurerm_key_vault_secret.app_password.value
  sensitive = true
}

output "key_vault_name" {
  value = azurerm_key_vault.default.name
}
