output "location" {
  value = data.azurerm_resource_group.default.location
}

output "one_subnet_id" {
  value = azurerm_subnet.one.id
}
output "public_ip" {
  value = azurerm_public_ip.default.id
}
