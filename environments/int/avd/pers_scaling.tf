# environments/int/avd — PERS personal host pools + personal scaling
# Catalog: pers_pools.tf (PERS-General + PERS-Packaging). Schedule from AVD-ScalingPlans.json.

locals {
  pers_personal_schedule = {
    weekdays = {
      properties = {
        daysOfWeek                        = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        rampUpStartTime                   = { hour = 0, minute = 0 }
        rampUpAutoStartHosts              = "None"
        rampUpStartVMOnConnect            = "Enable"
        rampUpActionOnDisconnect          = "Deallocate"
        rampUpMinutesToWaitOnDisconnect   = 90
        rampUpActionOnLogoff              = "Deallocate"
        rampUpMinutesToWaitOnLogoff       = 120
        peakStartTime                     = { hour = 0, minute = 30 }
        peakStartVMOnConnect              = "Enable"
        peakActionOnDisconnect            = "Deallocate"
        peakMinutesToWaitOnDisconnect     = 90
        peakActionOnLogoff                = "Deallocate"
        peakMinutesToWaitOnLogoff         = 120
        rampDownStartTime                 = { hour = 17, minute = 0 }
        rampDownStartVMOnConnect          = "Enable"
        rampDownActionOnDisconnect        = "Deallocate"
        rampDownMinutesToWaitOnDisconnect = 90
        rampDownActionOnLogoff            = "Deallocate"
        rampDownMinutesToWaitOnLogoff     = 120
        offPeakStartTime                  = { hour = 20, minute = 0 }
        offPeakStartVMOnConnect           = "Enable"
        offPeakActionOnDisconnect         = "Deallocate"
        offPeakMinutesToWaitOnDisconnect  = 90
        offPeakActionOnLogoff             = "Deallocate"
        offPeakMinutesToWaitOnLogoff      = 120
      }
    }
    weekend = {
      properties = {
        daysOfWeek                        = ["Saturday", "Sunday"]
        rampUpStartTime                   = { hour = 0, minute = 0 }
        rampUpAutoStartHosts              = "None"
        rampUpStartVMOnConnect            = "Enable"
        rampUpActionOnDisconnect          = "Deallocate"
        rampUpMinutesToWaitOnDisconnect   = 90
        rampUpActionOnLogoff              = "Deallocate"
        rampUpMinutesToWaitOnLogoff       = 120
        peakStartTime                     = { hour = 0, minute = 30 }
        peakStartVMOnConnect              = "Enable"
        peakActionOnDisconnect            = "Deallocate"
        peakMinutesToWaitOnDisconnect     = 90
        peakActionOnLogoff                = "Deallocate"
        peakMinutesToWaitOnLogoff         = 120
        rampDownStartTime                 = { hour = 17, minute = 0 }
        rampDownStartVMOnConnect          = "Enable"
        rampDownActionOnDisconnect        = "Deallocate"
        rampDownMinutesToWaitOnDisconnect = 90
        rampDownActionOnLogoff            = "Deallocate"
        rampDownMinutesToWaitOnLogoff     = 120
        offPeakStartTime                  = { hour = 20, minute = 0 }
        offPeakStartVMOnConnect           = "Enable"
        offPeakActionOnDisconnect         = "Deallocate"
        offPeakMinutesToWaitOnDisconnect  = 90
        offPeakActionOnLogoff             = "Deallocate"
        offPeakMinutesToWaitOnLogoff      = 120
      }
    }
  }
}

module "rg_pers_name" {
  count  = length(local.pers_host_pools) > 0 ? 1 : 0
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code
  environment     = local.env
  description     = "avd-pers"
}

resource "azurerm_resource_group" "pers" {
  count = length(local.pers_host_pools) > 0 ? 1 : 0

  name     = module.rg_pers_name[0].name
  location = local.location
  tags     = module.tags.tags
}

module "workspace_pers" {
  count  = length(local.pers_host_pools) > 0 ? 1 : 0
  source = "../../../modules/avd/workspace"

  name                = "pers"
  resource_group_name = azurerm_resource_group.pers[0].name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  # Legacy pipeline workspaceFriendlyname: RTL-DESKTOPS (int) / LIVE-DESKTOPS (prd)
  friendly_name = local.pers_workspace_friendly_name
  application_groups = {
    for k, v in local.pers_host_pools : k => {
      host_pool_id  = module.hostpool_pers[k].hostpool_id
      type          = "Desktop"
      friendly_name = "Desktop ${k}"
    }
  }

  tags = module.tags.tags
}

module "hostpool_pers" {
  source   = "../../../modules/avd/hostpool"
  for_each = local.pers_host_pools

  name                = "pers-${each.key}"
  resource_group_name = azurerm_resource_group.pers[0].name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  # Legacy create defaults: Personal / Direct / Persistent / max 9999 / startVMOnConnect true
  host_pool_type                   = "Personal"
  load_balancer_type               = "Persistent"
  personal_desktop_assignment_type = try(each.value.assignment_type, "Direct")
  preferred_app_group_type         = "Desktop"
  maximum_sessions_allowed         = 9999
  start_vm_on_connect              = true
  # PSM1 default tokenExpirationHours = 240 → PT240H10M
  token_validity_hours  = 240
  custom_rdp_properties = local.pers_rdp[try(each.value.rdp_persona, "standard")]
  description           = try(each.value.description, "PERS ${each.key}")
  friendly_name         = try(each.value.friendly_name, "pers-${each.key}")
  validate_environment  = try(each.value.validate_environment, false)

  log_analytics_workspace_id = var.law_id
  tags                       = module.tags.tags
}

module "scaling_plan_pers" {
  source   = "../../../modules/avd/scalingplan"
  for_each = local.pers_host_pools

  name                = "pers-${each.key}"
  resource_group_name = azurerm_resource_group.pers[0].name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  time_zone          = "GMT Standard Time"
  personal_schedules = local.pers_personal_schedule
  host_pool_associations = {
    (each.key) = {
      hostpool_id          = module.hostpool_pers[each.key].hostpool_id
      scaling_plan_enabled = true
    }
  }

  tags = module.tags.tags
}
