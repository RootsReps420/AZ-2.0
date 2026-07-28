terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0" # 4.x required: code uses 4.x-only args
    }
  }
}

provider "azurerm" {
  features {}
}
