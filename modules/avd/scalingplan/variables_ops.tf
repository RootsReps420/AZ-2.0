# Separate file so terraform-ls reliably indexes these inputs (used by env stacks).
variable "exclusion_tag" {
  description = "VM tag name that excludes session hosts from this scaling plan. Legacy uses spExclude."
  type        = string
  default     = null
  nullable    = true
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for scaling-plan diagnostics (allLogs). Null skips the diagnostic setting."
  type        = string
  default     = null
  nullable    = true
}
