variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the VDI Log Analytics workspace (ops and secOps are the same workspace in int/prd)."
  type        = string
}

variable "dce_name" {
  description = "Legacy pattern: uks-{env}-vdi-avd-dce-mult-all"
  type        = string
}

variable "dcr_main_name" {
  description = "Legacy pattern: uks-{env}-vdi-avd-dcr-mult"
  type        = string
}

variable "dcr_insights_name" {
  description = "Legacy pattern: uks-{env}-vdi-avd-dcr-mult-vminsights"
  type        = string
}

variable "dcr_fsl_name" {
  description = "Legacy pattern: uks-{env}-vdi-avd-dcr-multfslp"
  type        = string
}

variable "dcr_wss_name" {
  description = "Legacy pattern: uks-{env}-vdi-avd-dcr-multwss"
  type        = string
}

variable "fsl_log_file_pattern" {
  type    = string
  default = "C:\\ProgramData\\FSLogix\\Logs\\Profile\\*.log"
}

variable "wss_log_file_pattern" {
  type    = string
  default = "C:\\ProgramData\\Symantec WSS Agent\\wss-agent-log*.log"
}

variable "tags" {
  type    = map(string)
  default = {}
}
