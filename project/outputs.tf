output "subnet" {
  value = tolist(azurerm_virtual_network.default.subnet)[0]
}
