terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.69.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = "000000000000000000000000000000000000"
  resource_provider_registrations = "none"
}
