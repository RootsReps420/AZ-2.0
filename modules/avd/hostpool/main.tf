# ---------------------------------------------------------------------------
# AVD Host Pool
#
# Deploys an Azure Virtual Desktop Host Pool and issues a registration token
# used by session-host deployment pipelines (vdi-mult) to join VMs to the pool.
#
# The registration token is time-bound. We drive its expiry through a
# time_rotating resource so the token is re-issued automatically before it
# lapses — pipelines always have a valid token without manual rotation and
# without the perpetual-diff problem of timestamp()/timeadd().
#
# The host pool name comes from modules/naming (abbreviation vdh — PENDING(TDA)
# sign-off, LLD Open Item 2; TDA defines no AVD codes yet).
# ---------------------------------------------------------------------------

module "hostpool_name" {
  source = "../../naming"

  resource_type   = "avd_host_pool"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = var.name
  unique_id       = var.unique_id
}

# Rotates on the configured cadence. When it rotates, a fresh expiration_date
# flows into the registration info below and Azure mints a new token.
resource "time_rotating" "token" {
  rotation_hours = var.token_validity_hours
}

locals {
  # Bridge avoids terraform-ls confusing the dynamic block name with the variable.
  scheduled_agent_updates = var.scheduled_agent_updates
}

resource "azurerm_virtual_desktop_host_pool" "this" {
  name                = module.hostpool_name.name
  resource_group_name = var.resource_group_name
  location            = var.location

  type                     = var.host_pool_type
  load_balancer_type       = var.load_balancer_type
  preferred_app_group_type = var.preferred_app_group_type

  # Only meaningful for Pooled host pools; null on Personal pools.
  maximum_sessions_allowed = var.host_pool_type == "Pooled" ? var.maximum_sessions_allowed : null

  # Only meaningful for Personal host pools; null on Pooled pools.
  personal_desktop_assignment_type = var.host_pool_type == "Personal" ? var.personal_desktop_assignment_type : null

  friendly_name         = var.friendly_name
  description           = var.description
  validate_environment  = var.validate_environment
  start_vm_on_connect   = var.start_vm_on_connect
  custom_rdp_properties = var.custom_rdp_properties

  dynamic "scheduled_agent_updates" {
    for_each = local.scheduled_agent_updates != null ? [local.scheduled_agent_updates] : []
    content {
      enabled                   = scheduled_agent_updates.value.enabled
      timezone                  = scheduled_agent_updates.value.timezone
      use_session_host_timezone = scheduled_agent_updates.value.use_session_host_timezone

      dynamic "schedule" {
        for_each = scheduled_agent_updates.value.schedules
        content {
          day_of_week = schedule.value.day_of_week
          hour_of_day = schedule.value.hour_of_day
        }
      }
    }
  }

  tags = var.tags
}

# Registration token consumed by session-host deployment pipelines. Marked
# sensitive downstream via the module output.
resource "azurerm_virtual_desktop_host_pool_registration_info" "this" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = time_rotating.token.rotation_rfc3339
}

# Diagnostic settings — stream host pool logs to the platform Log Analytics
# workspace. Created only when a workspace id is supplied.
resource "azurerm_monitor_diagnostic_setting" "hostpool" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-to-law"
  target_resource_id         = azurerm_virtual_desktop_host_pool.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}
