variable "name" {
  description = "Descriptor for the management resources (e.g. \"vdi\"). Used as the description segment when generating names via modules/naming."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group into which the observability resources are deployed."
  type        = string
}

variable "location" {
  description = "Azure region for all resources in this module."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming inputs
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription/landing-zone segment used to name the resources (e.g. \"conn\")."
  type        = string
}

variable "environment" {
  description = "Environment segment used to name the resources (e.g. \"dev\", \"prod\")."
  type        = string
}

variable "unique_id" {
  description = "Optional uniqueness/instance suffix used when naming the resources (e.g. \"01\")."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Log Analytics Workspace
# ---------------------------------------------------------------------------

variable "law_sku" {
  description = "Log Analytics workspace SKU."
  type        = string
  default     = "PerGB2018"
}

variable "law_retention_in_days" {
  description = "Log Analytics data retention in days (30-730)."
  type        = number
  default     = 30

  validation {
    condition     = var.law_retention_in_days >= 30 && var.law_retention_in_days <= 730
    error_message = "law_retention_in_days must be between 30 and 730."
  }
}

variable "law_daily_quota_gb" {
  description = "Daily ingestion cap in GB. -1 means unlimited."
  type        = number
  default     = -1
}

variable "law_allow_resource_only_permissions" {
  description = "Legacy enableLogAccessUsingOnlyResourcePermissions. int=true, prd=false."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Data collection
# ---------------------------------------------------------------------------

variable "create_data_collection_endpoint" {
  description = "When true, create a Data Collection Endpoint (required for custom-log DCRs and used by the AVD Insights DCR)."
  type        = bool
  default     = false
}

variable "create_avd_insights_dcr" {
  description = "When true, create an AVD Insights Data Collection Rule collecting performance counters and Windows event logs into the workspace."
  type        = bool
  default     = false
}

variable "avd_dcr_sampling_seconds" {
  description = "Sampling frequency (seconds) for the AVD Insights performance counters."
  type        = number
  default     = 60
}

variable "avd_dcr_counters" {
  description = "Performance counter specifiers collected by the AVD Insights DCR."
  type        = list(string)
  default = [
    "\\LogicalDisk(C:)\\Avg. Disk Queue Length",
    "\\LogicalDisk(C:)\\% Free Space",
    "\\Memory\\Available Mbytes",
    "\\Memory\\Page Faults/sec",
    "\\Processor Information(_Total)\\% Processor Time",
    "\\User Input Delay per Session(*)\\Max Input Delay",
    "\\Terminal Services(*)\\Active Sessions",
    "\\Terminal Services(*)\\Inactive Sessions",
    "\\Terminal Services(*)\\Total Sessions",
  ]
}

variable "avd_dcr_event_xpaths" {
  description = "Windows event log XPath queries collected by the AVD Insights DCR."
  type        = list(string)
  default = [
    "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin!*",
    "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational!*",
    "System!*[System[(Level=1 or Level=2 or Level=3)]]",
    "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
  ]
}

# ---------------------------------------------------------------------------
# Action groups + alerts
# ---------------------------------------------------------------------------

variable "action_groups" {
  description = "Action groups keyed by short descriptor. short_name must be <= 12 chars."
  type = map(object({
    short_name = string
    enabled    = optional(bool, true)
    email_receivers = optional(map(object({
      email_address = string
    })), {})
    webhook_receivers = optional(map(object({
      service_uri = string
    })), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for ag in values(var.action_groups) : length(ag.short_name) <= 12])
    error_message = "Each action group short_name must be 12 characters or fewer."
  }
}

variable "metric_alerts" {
  description = "Metric alerts keyed by descriptor. action_group_keys reference keys in var.action_groups."
  type = map(object({
    scopes                   = list(string)
    description              = optional(string, "")
    severity                 = optional(number, 3)
    frequency                = optional(string, "PT5M")
    window_size              = optional(string, "PT15M")
    enabled                  = optional(bool, true)
    auto_mitigate            = optional(bool, true)
    target_resource_type     = optional(string)
    target_resource_location = optional(string)
    display_name             = optional(string) # override naming-module name when set
    action_group_keys        = optional(list(string), [])
    criteria = object({
      metric_namespace = string
      metric_name      = string
      aggregation      = string
      operator         = string
      threshold        = number
      dimensions = optional(list(object({
        name     = string
        operator = string
        values   = list(string)
      })), [])
    })
  }))
  default = {}
}

variable "activity_log_alerts" {
  description = "Activity log alerts keyed by descriptor. action_group_keys reference keys in var.action_groups."
  type = map(object({
    scopes            = list(string)
    description       = optional(string, "")
    action_group_keys = optional(list(string), [])
    criteria = object({
      category       = string
      operation_name = optional(string)
      level          = optional(string)
      resource_type  = optional(string)
    })
  }))
  default = {}
}

variable "scheduled_query_alerts" {
  description = "Scheduled query (log) alerts keyed by descriptor. action_group_keys reference keys in var.action_groups."
  type = map(object({
    query                             = string
    severity                          = optional(number, 3)
    evaluation_frequency              = optional(string, "PT5M")
    window_duration                   = optional(string, "PT15M")
    time_aggregation_method           = optional(string, "Count")
    threshold                         = optional(number, 0)
    operator                          = optional(string, "GreaterThan")
    description                       = optional(string, "")
    enabled                           = optional(bool, true)
    auto_mitigation_enabled           = optional(bool, true)
    mute_actions_after_alert_duration = optional(string)       # e.g. PT24H; null = no mute
    scopes                            = optional(list(string)) # default: this module's LAW
    action_group_keys                 = optional(list(string), [])
    identity_ids                      = optional(list(string), []) # user-assigned identities (quota ARG queries)
    metric_measure_column             = optional(string)
    resource_id_column                = optional(string)
    display_name                      = optional(string) # override naming-module name when set
  }))
  default = {}
}

variable "workbooks" {
  description = "Azure Monitor workbooks keyed by descriptor. data_json is the serialised workbook template."
  type = map(object({
    display_name = string
    data_json    = string
  }))
  default = {}
}

variable "tags" {
  description = "Merged tag map (output of modules/tags) applied to all resources."
  type        = map(string)
  default     = {}
}
