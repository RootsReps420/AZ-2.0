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
  # Required when storage accounts set shared_access_key_enabled=false (legacy
  # allowSharedKeyAccess=false). Without this, apply polls blob data plane with
  # account keys and fails: KeyBasedAuthenticationNotPermitted.
  # Deploy SP needs Storage Blob Data Contributor on the labs RG / subscription.
  storage_use_azuread = true
  features {}
  subscription_id     = var.azure_subscription_id
}
