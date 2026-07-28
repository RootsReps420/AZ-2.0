terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0" # 4.x required: code uses 4.x-only args (rbac_authorization_enabled, https_traffic_only_enabled, enabled_metric)
    }
  }
}
