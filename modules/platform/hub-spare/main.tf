# ---------------------------------------------------------------------------
# Hub03 — Spare / bare Virtual Hub
#
# Deploys an empty virtual hub attached to the shared Virtual WAN. No Azure
# Firewall, no Routing Intent, no ExpressRoute gateway, no VPN gateway, and no
# spoke connections. Azure allows creating a hub without gateways and adding
# them later; empty-hub pricing still applies.
#
# Purpose (Azure 2.0): reserve address space and membership in the vWAN full
# mesh so that, if this hub is ever used, private traffic can traverse Hub01's
# Azure Firewall via Routing Intent (RFC1918 and other private routes). Today
# this is address reservation + mesh membership only — not a live VDI path.
#
# All resource names come from modules/naming — never hardcoded.
# ---------------------------------------------------------------------------

module "hub_name" {
  source = "../../naming"

  resource_type   = "virtual_hub"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = var.name
  unique_id       = var.unique_id
}

resource "azurerm_virtual_hub" "this" {
  name                   = module.hub_name.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  virtual_wan_id         = var.virtual_wan_id
  address_prefix         = var.address_prefix
  hub_routing_preference = var.hub_routing_preference
  tags                   = var.tags
}
