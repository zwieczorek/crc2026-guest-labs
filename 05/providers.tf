terraform {
  required_version = "~> 1.10"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.70.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id                 = "ID_HERE"
  resource_provider_registrations = "none"
}

