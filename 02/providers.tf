terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.69.0" # check if newest version is available
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = "XXXXX"
  resource_provider_registrations = "none"
}
