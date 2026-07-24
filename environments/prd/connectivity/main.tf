# environments/int/connectivity — Hub01 + Hub02 + baseline firewall policy
# IP ranges from legacy platform params/int/config.yml (verbatim).

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
  source = "../../../modules/platform/hub-secured"

  name                = "hub01"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  virtual_wan_id     = var.virtual_wan_id
  address_prefix     = var.hub01_address_prefix
  firewall_policy_id = module.firewall_policy.policy_id

  express_route = {
    scale_units        = 1
    circuit_peering_id = var.expressroute_circuit_peering_id
  }

  tags = module.tags.tags
}

module "hub_unsecured" {
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
