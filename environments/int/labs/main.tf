# environments/int/labs — PERS + MSH spokes (session hosts stay PS)
# CIDRs from legacy platform/pers params/int/config.yml (VERIFIED).
# NSG rules: nsg_rules.tf (legacy labCorePersistent / labCoreMulti).
# FSLogix shares: fslogix_shares.tf (INT RTL = 100 GB each).

locals {
  location = var.location
  env      = var.environment
}

module "tags_pers" {
  source = "../../../modules/tags"

  workload    = "vdi-pers"
  environment = local.env
  region      = local.location
  mandatory   = var.mandatory_tags
}

module "tags_mult" {
  source = "../../../modules/tags"

  workload    = "vdi-mult"
  environment = local.env
  region      = local.location
  mandatory   = var.mandatory_tags
}

module "rg_pers_name" {
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code
  environment     = local.env
  description     = "pers-labs"
}

module "rg_mult_name" {
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code
  environment     = local.env
  description     = "mult-labs"
}

resource "azurerm_resource_group" "pers" {
  name     = module.rg_pers_name.name
  location = local.location
  tags     = module.tags_pers.tags
}

resource "azurerm_resource_group" "mult" {
  name     = module.rg_mult_name.name
  location = local.location
  tags     = module.tags_mult.tags
}

# PERS lab spokes — for_each over map from config.yml net_lab_core_pers_*
module "spoke_pers" {
  source   = "../../../modules/core/spoke-pers"
  for_each = var.pers_spokes

  name                = "pers-${each.key}"
  resource_group_name = azurerm_resource_group.pers.name
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
      security_rules        = local.pers_security_rules[each.key]
    }
  }

  hub01_id                  = var.hub01_id
  hub01_firewall_private_ip = var.hub01_firewall_private_ip
  tags                      = module.tags_pers.tags
}

# MSH lab spokes — dual hub + UDR scaffold (Hub02 VPN next-hop still PENDING)
module "spoke_msh" {
  source   = "../../../modules/core/spoke-msh"
  for_each = var.msh_spokes

  name                = "mult-${each.key}"
  resource_group_name = azurerm_resource_group.mult.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env
  unique_id           = each.key

  address_space = each.value.address_space
  dns_servers   = var.dns_servers
  subnets = {
    for name, cidr in each.value.avd_subnets : name => {
      address_prefixes      = [cidr]
      associate_route_table = true
      service_endpoints     = ["Microsoft.Storage", "Microsoft.KeyVault"]
      security_rules        = local.msh_security_rules[each.key]
    }
  }

  hub01_id                  = var.hub01_id
  hub02_id                  = var.hub02_id
  hub01_firewall_private_ip = var.hub01_firewall_private_ip

  tags = module.tags_mult.tags
}

# FSLogix storage (MSH) — 10 STAs (legacy p_FSLogixSta); profile ops stay PS
module "storage_fslogix" {
  for_each = var.enable_fslogix ? local.fslogix_stas : {}
  source   = "../../../modules/core/storage-fslogix"

  name                = "multilb${each.value.lab}pf"
  resource_group_name = azurerm_resource_group.mult.name
  location            = local.location
  subscription_id     = ""
  environment         = local.env
  unique_id           = each.value.bu
  name_override       = local.fslogix_legacy_sta_name[each.key]

  public_network_access_enabled     = true
  shared_access_key_enabled         = false
  infrastructure_encryption_enabled = true

  azure_files_authentication = {
    directory_type = "AADKERB"
    active_directory = {
      domain_name = local.fslogix_aadkerb.domain_name
      domain_guid = local.fslogix_aadkerb.domain_guid
    }
  }

  smb = {
    versions                        = ["SMB3.1.1"]
    authentication_types            = ["Kerberos"]
    kerberos_ticket_encryption_type = ["AES-256"]
    channel_encryption_type         = ["AES-256-GCM"]
    multichannel_enabled            = true
  }

  network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    virtual_network_subnet_ids = compact([
      module.spoke_msh[each.value.lab].subnet_ids[each.value.avd_subnet],
      var.agents_subnet_id,
    ])
  }

  shares                     = local.fslogix_shares_by_sta[each.key]
  log_analytics_workspace_id = var.law_id

  tags = module.tags_mult.tags
}
