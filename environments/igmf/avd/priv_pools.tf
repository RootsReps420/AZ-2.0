# PRIV personal host pool — from legacy scripts PRIV-General_* (pool 001-01).
# Separate workspace from PERS (PRIV-DESKTOPS). Robot stays out (RDP broker, not AVD).

locals {
  priv_host_pools_catalog = {
    "001-01" = { rdp_persona = "copypaste", description = "PRIV-General copypaste" }
  }

  enable_priv_host_pools   = var.enable_priv_host_pools
  priv_host_pools_override = var.priv_host_pools

  priv_host_pools = local.enable_priv_host_pools ? (
    length(local.priv_host_pools_override) > 0 ? local.priv_host_pools_override : local.priv_host_pools_catalog
  ) : {}
}

module "rg_priv_avd_name" {
  count  = length(local.priv_host_pools) > 0 ? 1 : 0
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code
  environment     = local.env
  description     = "avd-priv"
}

resource "azurerm_resource_group" "priv_avd" {
  count = length(local.priv_host_pools) > 0 ? 1 : 0

  name     = module.rg_priv_avd_name[0].name
  location = local.location
  tags     = module.tags_priv.tags
}

module "workspace_priv" {
  count  = length(local.priv_host_pools) > 0 ? 1 : 0
  source = "../../../modules/avd/workspace"

  name                = "priv"
  resource_group_name = azurerm_resource_group.priv_avd[0].name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  friendly_name = "PRIV-DESKTOPS"
  application_groups = {
    for k, v in local.priv_host_pools : k => {
      host_pool_id  = module.hostpool_priv[k].hostpool_id
      type          = "Desktop"
      friendly_name = "PRIV ${k}"
    }
  }

  tags = module.tags_priv.tags
}

module "hostpool_priv" {
  source   = "../../../modules/avd/hostpool"
  for_each = local.priv_host_pools

  name                = "priv-${each.key}"
  resource_group_name = azurerm_resource_group.priv_avd[0].name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  host_pool_type                   = "Personal"
  load_balancer_type               = "Persistent"
  personal_desktop_assignment_type = try(each.value.assignment_type, "Direct")
  preferred_app_group_type         = "Desktop"
  maximum_sessions_allowed         = 9999
  start_vm_on_connect              = true
  token_validity_hours             = 240
  custom_rdp_properties            = local.pers_rdp[try(each.value.rdp_persona, "copypaste")]
  description                      = try(each.value.description, "PRIV ${each.key}")
  friendly_name                    = try(each.value.friendly_name, "priv-${each.key}")
  validate_environment             = try(each.value.validate_environment, false)

  log_analytics_workspace_id = var.law_id
  tags                       = module.tags_priv.tags
}

module "scaling_plan_priv" {
  source   = "../../../modules/avd/scalingplan"
  for_each = local.priv_host_pools

  name                = "priv-${each.key}"
  resource_group_name = azurerm_resource_group.priv_avd[0].name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  time_zone          = "GMT Standard Time"
  personal_schedules = local.pers_personal_schedule
  host_pool_associations = {
    (each.key) = {
      hostpool_id          = module.hostpool_priv[each.key].hostpool_id
      scaling_plan_enabled = true
    }
  }

  tags = module.tags_priv.tags

  depends_on = [time_sleep.wvd_power_on_off]
}
