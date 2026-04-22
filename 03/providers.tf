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
  subscription_id                 = "ID_HERE"
  resource_provider_registrations = "none"
}
