variable "name" {
  description = "Descriptor for the host pool (e.g. \"vdi-mult-fin\"). Used as the description segment when generating the name via modules/naming."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group into which the host pool is deployed."
  type        = string
}

variable "location" {
  description = "Azure region for the host pool."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming inputs — passed through to modules/naming
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription/landing-zone segment used to name the host pool (e.g. \"vdi\")."
  type        = string
}

variable "environment" {
  description = "Environment segment used to name the host pool (e.g. \"dev\", \"prod\")."
  type        = string
}

variable "unique_id" {
  description = "Optional uniqueness/instance suffix used when naming the host pool (e.g. \"01\")."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Host pool shape
# ---------------------------------------------------------------------------

variable "host_pool_type" {
  description = "Host pool type. One of: Personal, Pooled."
  type        = string

  validation {
    condition     = contains(["Personal", "Pooled"], var.host_pool_type)
    error_message = "host_pool_type must be either Personal or Pooled."
  }
}

variable "load_balancer_type" {
  description = "Session-host load balancing algorithm. Use BreadthFirst or DepthFirst for Pooled pools, and Persistent for Personal pools."
  type        = string
  default     = "BreadthFirst"

  validation {
    condition     = contains(["BreadthFirst", "DepthFirst", "Persistent"], var.load_balancer_type)
    error_message = "load_balancer_type must be one of: BreadthFirst, DepthFirst, Persistent."
  }
}

variable "maximum_sessions_allowed" {
  description = "Maximum concurrent sessions per session host. Applies to Pooled host pools only (ignored for Personal). Range 1-999999."
  type        = number
  default     = 16

  validation {
    condition     = var.maximum_sessions_allowed >= 1 && var.maximum_sessions_allowed <= 999999
    error_message = "maximum_sessions_allowed must be between 1 and 999999."
  }
}

variable "personal_desktop_assignment_type" {
  description = "Desktop assignment mode for Personal host pools. One of: Automatic, Direct. Ignored for Pooled host pools."
  type        = string
  default     = "Automatic"

  validation {
    condition     = contains(["Automatic", "Direct"], var.personal_desktop_assignment_type)
    error_message = "personal_desktop_assignment_type must be either Automatic or Direct."
  }
}

variable "preferred_app_group_type" {
  description = "Preferred application group type surfaced to users. One of: Desktop, RailApplications, None."
  type        = string
  default     = "Desktop"

  validation {
    condition     = contains(["Desktop", "RailApplications", "None"], var.preferred_app_group_type)
    error_message = "preferred_app_group_type must be one of: Desktop, RailApplications, None."
  }
}

variable "custom_rdp_properties" {
  description = "Semicolon-delimited RDP properties applied to connections (e.g. \"audiocapturemode:i:1;drivestoredirect:s:;redirectclipboard:i:0\"). Null leaves Azure defaults in place."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Registration token
# ---------------------------------------------------------------------------

variable "token_validity_hours" {
  description = "Validity window of the session-host registration token, in hours. The token rotates automatically on this cadence. Azure permits between 1 hour and 30 days (720 hours). Legacy Bicep uses PT175H10M (~175h)."
  type        = number
  default     = 175

  validation {
    condition     = var.token_validity_hours >= 1 && var.token_validity_hours <= 720
    error_message = "token_validity_hours must be between 1 and 720 (1 hour to 30 days)."
  }
}

# ---------------------------------------------------------------------------
# Metadata
# ---------------------------------------------------------------------------

variable "friendly_name" {
  description = "Display name shown to users in the AVD client."
  type        = string
  default     = null
}

variable "description" {
  description = "Free-text description of the host pool."
  type        = string
  default     = null
}

variable "validate_environment" {
  description = "When true, opts the host pool into the validation environment for early feature/agent updates."
  type        = bool
  default     = false
}

variable "start_vm_on_connect" {
  description = "When true, allows session hosts to be started on connect (requires the Start VM on Connect configuration on the pool's VMs)."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace (output law_id from modules/platform/management) to send host pool diagnostics to. When null, no diagnostic setting is created."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the host pool."
  type        = map(string)
  default     = {}
}
