# environments/prd/connectivity — Hub01 + Hub02 + baseline firewall policy
# Azure 2.0 hub address plan: 10.218.64.0/20 as three /22 hubs (see docs/address-plan-hubs.md).
# Hub03 spare (10.218.72.0/22) is kept in code but NOT deployed — see commented module below.
# enable_hub01 / enable_hub02 gate modules for phased pipeline deploys (one state file).

locals {
  location = var.location
  env      = var.environment
}

module "tags" {
  source = "../../../modules/tags"

  workload    = "vdi-platform"
  environment = local.env
  region      = local.location
  mandatory   = var.mandatory_tags
}

module "rg_name" {
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code
  environment     = local.env
  description     = "connectivity"
}

resource "azurerm_resource_group" "connectivity" {
  name     = module.rg_name.name
  location = local.location
  tags     = module.tags.tags
}

# Baseline / stub policy so AZFW_Hub can attach. Full Secure-Hub rules → Azure Policy workstream.
module "firewall_policy" {
  count  = var.enable_hub01 ? 1 : 0
  source = "../../../modules/platform/firewall-policy"

  name                = "hub01"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  sku = "Standard"
  dns = {
    proxy_enabled = true
    servers       = var.dns_servers
  }

  # TODO(deploy): add thin smoke-test allow collections under Routing Intent if needed.
  tags = module.tags.tags
}

module "hub_secured" {
  count  = var.enable_hub01 ? 1 : 0
  source = "../../../modules/platform/hub-secured"

  name                = "hub01"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  virtual_wan_id     = var.virtual_wan_id
  address_prefix     = var.hub01_address_prefix
  firewall_policy_id = module.firewall_policy[0].policy_id

  express_route = {
    scale_units        = 1
    circuit_peering_id = var.expressroute_circuit_peering_id
  }

  tags = module.tags.tags
}

module "hub_unsecured" {
  count  = var.enable_hub02 ? 1 : 0
  source = "../../../modules/platform/hub-unsecured"

  name                = "hub02"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  virtual_wan_id = var.virtual_wan_id
  address_prefix = var.hub02_address_prefix

  # TODO(deploy): VPN site/connection + real scale/BGP when other engineer config lands.
  vpn = {
    scale_unit         = 1
    routing_preference = "Microsoft Network"
  }

  tags = module.tags.tags
}

# SPARE (not deployed): Hub03 bare hub — reserved CIDR var.hub03_address_prefix
# (default 10.218.72.0/22). Uncomment module "hub_spare" when a region needs it.
# Module is region-agnostic (uses var.location). No FW/VPN/ER/spokes.
#
# module "hub_spare" {
#   source = "../../../modules/platform/hub-spare"
#
#   name                = "hub03"
#   resource_group_name = azurerm_resource_group.connectivity.name
#   location            = local.location
#   subscription_id     = var.subscription_code
#   environment         = local.env
#
#   virtual_wan_id = var.virtual_wan_id
#   address_prefix = var.hub03_address_prefix
#
#   tags = module.tags.tags
# }
