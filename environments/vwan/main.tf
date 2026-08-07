# ---------------------------------------------------------------------------
# environments/_global
#
# Resources deployed ONCE and shared across all regions/environments.
# Currently: the global Virtual WAN (+ its resource group).
#
# This root config contains only configuration — variable values and calls to
# modules. All logic lives in modules/.
# ---------------------------------------------------------------------------

module "tags" {
  source = "../../modules/tags"

  workload    = "vdi-platform"
  environment = var.environment
  region      = var.location
  mandatory   = var.mandatory_tags
}

module "rg_name" {
  source = "../../modules/naming"

  resource_type   = "resource_group"
  location        = var.location
  subscription_id = var.subscription_code
  environment     = var.environment
  description     = "global"
}

resource "azurerm_resource_group" "global" {
  name     = module.rg_name.name
  location = var.location
  tags     = module.tags.tags
}

module "vwan" {
  source = "../../modules/platform/vwan"

  resource_group_name = azurerm_resource_group.global.name
  location            = var.location
  sku                 = "Standard"

  subscription_id = var.subscription_code
  environment     = var.environment
  description     = "vdi"
  unique_id       = "01"

  tags = module.tags.tags
}
