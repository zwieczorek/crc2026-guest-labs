data "azurerm_resource_group" "main" {
  name = "rg-crc2026-student-XXX-lab"
}

data "azurerm_client_config" "current" {}
