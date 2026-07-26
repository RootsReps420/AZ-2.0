variable "name" {
  description = "Descriptor for the scaling plan (e.g. \"pers-uks\"). Used as the description segment when generating the name via modules/naming."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group into which the scaling plan is deployed."
  type        = string
}

variable "location" {
  description = "Azure region for the scaling plan."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming inputs
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription/landing-zone segment used to name the scaling plan (e.g. \"vdi\")."
  type        = string
}

variable "environment" {
  description = "Environment segment used to name the scaling plan (e.g. \"dev\", \"prod\")."
  type        = string
}

variable "unique_id" {
  description = "Optional uniqueness/instance suffix used when naming the scaling plan (e.g. \"01\")."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Scaling plan
# ---------------------------------------------------------------------------

variable "friendly_name" {
  description = "Display name of the scaling plan."
  type        = string
  default     = null
}

variable "description" {
  description = "Free-text description of the scaling plan."
  type        = string
  default     = null
}

variable "time_zone" {
  description = "Time zone the schedules are evaluated in (e.g. \"GMT Standard Time\")."
  type        = string
  default     = "GMT Standard Time"
}

variable "host_pool_associations" {
  description = "Host pools this scaling plan applies to, keyed by descriptor. scaling_plan_enabled toggles enforcement per pool."
  type = map(object({
    hostpool_id          = string
    scaling_plan_enabled = optional(bool, true)
  }))
  default = {}
}

variable "pooled_schedules" {
  description = "Pooled host pool schedules keyed by schedule name (native azurerm)."
  type = map(object({
    days_of_week = list(string)

    ramp_up_start_time                 = string
    ramp_up_load_balancing_algorithm   = optional(string, "BreadthFirst")
    ramp_up_minimum_hosts_percent      = optional(number, 20)
    ramp_up_capacity_threshold_percent = optional(number, 60)

    peak_start_time                   = string
    peak_load_balancing_algorithm     = optional(string, "BreadthFirst")
    off_peak_start_time               = string
    off_peak_load_balancing_algorithm = optional(string, "DepthFirst")

    ramp_down_start_time                 = string
    ramp_down_load_balancing_algorithm   = optional(string, "DepthFirst")
    ramp_down_minimum_hosts_percent      = optional(number, 10)
    ramp_down_capacity_threshold_percent = optional(number, 90)
    ramp_down_force_logoff_users         = optional(bool, false)
    ramp_down_wait_time_minutes          = optional(number, 30)
    ramp_down_notification_message       = optional(string, "You will be logged off soon. Please save your work.")
    ramp_down_stop_hosts_when            = optional(string, "ZeroSessions")
  }))
  default = {}
}

variable "personal_schedules" {
  description = <<-EOT
    Personal desktop schedules keyed by schedule name (via azapi). The properties
    object is passed straight to the ARM body. Typical keys include daysOfWeek,
    rampUpStartTime {hour, minute}, rampUpAutoStartHosts, rampUpActionOnDisconnect,
    rampUpMinutesToWaitOnDisconnect, peakStartTime, peakActionOnDisconnect,
    rampDownStartTime, offPeakStartTime, offPeakActionOnDisconnect, etc.
  EOT
  type = map(object({
    properties = any
  }))
  default = {}
}

variable "tags" {
  description = "Merged tag map (output of modules/tags) applied to the scaling plan."
  type        = map(string)
  default     = {}
}
