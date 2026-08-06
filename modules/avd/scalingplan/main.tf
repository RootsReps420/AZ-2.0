# ---------------------------------------------------------------------------
# AVD Scaling Plan
#
# Deploys an AVD Scaling Plan, associates it with host pools, and defines its
# schedules.
#
#   - Pooled schedules       -> native azurerm `schedule` blocks
#   - Personal schedules     -> azapi (Microsoft.DesktopVirtualization/
#                               scalingPlans/personalSchedules). The azurerm
#                               provider (<= 4.x) has no native resource for
#                               personal schedules, so azapi is used. This is the
#                               path used by PERS (personal desktop) workloads.
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

  # azurerm_virtual_desktop_scaling_plan requires ≥1 `schedule` block even when
  # real schedules are personal (azapi). PERS/PRIV pass only personal_schedules —
  # without a placeholder, plan fails: "Insufficient schedule blocks".
  # Name must start/end alphanumeric (Azure rejects leading underscore).
  # Real personal behaviour comes from azapi_resource.personal_schedule below.
  pooled_schedules_effective = length(var.pooled_schedules) > 0 ? var.pooled_schedules : (
    length(var.personal_schedules) > 0 ? {
      "tfplaceholder" = {
        days_of_week                         = ["Monday"]
        ramp_up_start_time                   = "00:00"
        ramp_up_load_balancing_algorithm     = "BreadthFirst"
        ramp_up_minimum_hosts_percent        = 0
        ramp_up_capacity_threshold_percent   = 100
        peak_start_time                      = "00:01"
        peak_load_balancing_algorithm        = "BreadthFirst"
        ramp_down_start_time                 = "23:58"
        ramp_down_load_balancing_algorithm   = "DepthFirst"
        ramp_down_minimum_hosts_percent      = 0
        ramp_down_capacity_threshold_percent = 100
        ramp_down_force_logoff_users         = false
        ramp_down_wait_time_minutes          = 30
        ramp_down_notification_message       = "placeholder"
        ramp_down_stop_hosts_when            = "ZeroSessions"
        off_peak_start_time                  = "23:59"
        off_peak_load_balancing_algorithm    = "DepthFirst"
      }
    } : {}
  )
}

resource "azurerm_virtual_desktop_scaling_plan" "this" {
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

  # Pooled schedules (native azurerm).
  dynamic "schedule" {
    for_each = local.pooled_schedules_effective
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

# Personal schedules (azapi). The `properties` object is passed through to the
# ARM body so the full personal-schedule surface is available without azurerm
# support. See README for the expected shape.
resource "azapi_resource" "personal_schedule" {
  for_each = var.personal_schedules

  type      = "Microsoft.DesktopVirtualization/scalingPlans/personalSchedules@2024-04-03"
  name      = each.key
  parent_id = azurerm_virtual_desktop_scaling_plan.this.id

  body = {
    properties = each.value.properties
  }
}

# Legacy vdi_hp_resources.bicep: categoryGroup allLogs → secOps LAW
resource "azurerm_monitor_diagnostic_setting" "scaling_plan" {
  count = local.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-to-law"
  target_resource_id         = azurerm_virtual_desktop_scaling_plan.this.id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}
