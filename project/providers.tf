terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.69.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.2.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~>2.8.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = "000000000000000000000000000000000000"
  resource_provider_registrations = "none"
}
