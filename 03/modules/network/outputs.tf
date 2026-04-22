output "name" {
  value = azurerm_virtual_network.default.id
}

output "location" {
  value = data.azurerm_resource_group.default.location
}
