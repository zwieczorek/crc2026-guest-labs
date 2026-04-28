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
  subscription_id                 = "d44fd3bd-b452-4423-a71e-544b9c31f4d9"
  resource_provider_registrations = "none"
}

