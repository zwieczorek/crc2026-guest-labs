terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.65.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = "ID_HERE"
  resource_provider_registrations = "none"
}
