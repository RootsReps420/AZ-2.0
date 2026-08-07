# ---------------------------------------------------------------------------
# modules/core/demo-module
#
# Demo scaffold from test run
#
# Conventions:
#   - Resource names from modules/naming - never hardcode names.
#   - Tags from var.tags (caller merges via modules/tags).
#   - location is always a variable; never bake in a region.
# ---------------------------------------------------------------------------

module "demo_module_name" {
  source = "../../naming"

  # TODO(deploy): set resource_type to a key known by modules/naming
  # (e.g. "key_vault", "storage_account", "virtual_desktop_host_pool").
  resource_type   = "demo_module"
  location        = var.location
  environment     = var.environment
  subscription_id = var.subscription_id
  description     = var.description
  unique_id       = var.unique_id
}

# TODO(deploy): replace with the real Azure resource(s).
# resource "azurerm_TODO" "this" {
#   name                = module.demo_module_name.name
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   tags                = var.tags
# }