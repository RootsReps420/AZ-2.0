# ---------------------------------------------------------------------------
# AVD Scaling Plan
#
# Deploys an AVD Scaling Plan, associates it with host pools, and defines its
# schedules.
#
#   - Pooled plans           -> native azurerm_virtual_desktop_scaling_plan
#   - Personal plans         -> azapi (hostPoolType=Personal). azurerm (<= 4.x)
#                               only creates Pooled plans; a placeholder pooled
#                               schedule cannot be used with Personal host pools.
#   - Personal schedules     -> azapi child resources (personalSchedules)
#
# Names come from modules/naming (abbreviation vds — PENDING(TDA) sign-off,
# LLD Open Item 2; TDA defines no AVD codes yet).
# ---------------------------------------------------------------------------

module "scaling_plan_name" {
  source = "../../naming"

  resource_type   = "avd_scaling_plan"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = var.name
  unique_id       = var.unique_id
}

locals {
  exclusion_tag              = var.exclusion_tag
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Personal host pools require hostPoolType=Personal (immutable after create).
  # azurerm always creates Pooled — use azapi when only personal schedules are set.
  is_personal_plan = length(var.personal_schedules) > 0 && length(var.pooled_schedules) == 0

  # one(concat(...)) avoids evaluating [0] on a zero-count resource.
  scaling_plan_id   = one(concat(azapi_resource.personal_plan[*].id, azurerm_virtual_desktop_scaling_plan.this[*].id))
  scaling_plan_name = module.scaling_plan_name.name
}

data "azurerm_resource_group" "this" {
  count = local.is_personal_plan ? 1 : 0
  name  = var.resource_group_name
}

# ---------------------------------------------------------------------------
# Pooled scaling plan (azurerm)
# ---------------------------------------------------------------------------

resource "azurerm_virtual_desktop_scaling_plan" "this" {
  count = local.is_personal_plan ? 0 : 1

  name                = module.scaling_plan_name.name
  resource_group_name = var.resource_group_name
  location            = var.location
  friendly_name       = var.friendly_name
  description         = var.description
  time_zone           = var.time_zone
  exclusion_tag       = local.exclusion_tag
  tags                = var.tags

  dynamic "host_pool" {
    for_each = var.host_pool_associations
    content {
      hostpool_id          = host_pool.value.hostpool_id
      scaling_plan_enabled = host_pool.value.scaling_plan_enabled
    }
  }

  dynamic "schedule" {
    for_each = var.pooled_schedules
    content {
      name         = schedule.key
      days_of_week = schedule.value.days_of_week

      ramp_up_start_time                 = schedule.value.ramp_up_start_time
      ramp_up_load_balancing_algorithm   = schedule.value.ramp_up_load_balancing_algorithm
      ramp_up_minimum_hosts_percent      = schedule.value.ramp_up_minimum_hosts_percent
      ramp_up_capacity_threshold_percent = schedule.value.ramp_up_capacity_threshold_percent

      peak_start_time                   = schedule.value.peak_start_time
      peak_load_balancing_algorithm     = schedule.value.peak_load_balancing_algorithm
      off_peak_start_time               = schedule.value.off_peak_start_time
      off_peak_load_balancing_algorithm = schedule.value.off_peak_load_balancing_algorithm

      ramp_down_start_time                 = schedule.value.ramp_down_start_time
      ramp_down_load_balancing_algorithm   = schedule.value.ramp_down_load_balancing_algorithm
      ramp_down_minimum_hosts_percent      = schedule.value.ramp_down_minimum_hosts_percent
      ramp_down_capacity_threshold_percent = schedule.value.ramp_down_capacity_threshold_percent
      ramp_down_force_logoff_users         = schedule.value.ramp_down_force_logoff_users
      ramp_down_wait_time_minutes          = schedule.value.ramp_down_wait_time_minutes
      ramp_down_notification_message       = schedule.value.ramp_down_notification_message
      ramp_down_stop_hosts_when            = schedule.value.ramp_down_stop_hosts_when
    }
  }
}

# ---------------------------------------------------------------------------
# Personal scaling plan (azapi) — hostPoolType=Personal
# ---------------------------------------------------------------------------

resource "azapi_resource" "personal_plan" {
  count = local.is_personal_plan ? 1 : 0

  type      = "Microsoft.DesktopVirtualization/scalingPlans@2024-04-03"
  name      = module.scaling_plan_name.name
  parent_id = data.azurerm_resource_group.this[0].id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      friendlyName = var.friendly_name
      description  = var.description
      timeZone     = var.time_zone
      hostPoolType = "Personal"
      exclusionTag = local.exclusion_tag
      hostPoolReferences = [
        for _, a in var.host_pool_associations : {
          hostPoolArmPath    = a.hostpool_id
          scalingPlanEnabled = a.scaling_plan_enabled
        }
      ]
    }
  }
}

# Personal schedules (azapi children of either plan type).
resource "azapi_resource" "personal_schedule" {
  for_each = var.personal_schedules

  type      = "Microsoft.DesktopVirtualization/scalingPlans/personalSchedules@2024-04-03"
  name      = each.key
  parent_id = local.scaling_plan_id

  body = {
    properties = each.value.properties
  }
}

# Legacy vdi_hp_resources.bicep: categoryGroup allLogs → secOps LAW
resource "azurerm_monitor_diagnostic_setting" "scaling_plan" {
  count = local.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-to-law"
  target_resource_id         = local.scaling_plan_id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}
