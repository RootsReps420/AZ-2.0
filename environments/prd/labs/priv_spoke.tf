# labCorePriv — privileged AVD spoke (01a).
# Legacy had a local Azure Firewall in this VNet; post-vWAN cutover uses Hub01
# default-to-firewall (same as PERS). Firewall subnet CIDRs remain in address_space
# as reserved space but are not deployed as AzureFirewall* subnets here.

module "tags_priv" {
  source = "../../../modules/tags"

  workload    = "priv"
  environment = local.env
  region      = local.location
  mandatory   = var.mandatory_tags
}

module "rg_priv_name" {
  count  = length(var.priv_spokes) > 0 ? 1 : 0
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code
  environment     = local.env
  description     = "priv-labs"
}

resource "azurerm_resource_group" "priv" {
  count = length(var.priv_spokes) > 0 ? 1 : 0

  name     = module.rg_priv_name[0].name
  location = local.location
  tags     = module.tags_priv.tags
}

module "spoke_priv" {
  source   = "../../../modules/core/spoke-pers"
  for_each = var.priv_spokes

  name                = "priv-${each.key}"
  resource_group_name = azurerm_resource_group.priv[0].name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env
  unique_id           = each.key

  address_space = each.value.address_space
  dns_servers   = var.dns_servers
  subnets = {
    "AVDSubnet" = {
      address_prefixes      = each.value.avd_subnet
      associate_route_table = true
      service_endpoints     = ["Microsoft.Storage", "Microsoft.KeyVault"]
      security_rules        = local.priv_security_rules[each.key]
    }
  }

  hub01_id                  = var.hub01_id
  hub01_firewall_private_ip = var.hub01_firewall_private_ip
  tags                      = module.tags_priv.tags
}
