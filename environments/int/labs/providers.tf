terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  # Required when labs storage uses shared_access_key_enabled=false (legacy).
  storage_use_azuread = true
  features {}
  subscription_id     = var.azure_subscription_id
}
