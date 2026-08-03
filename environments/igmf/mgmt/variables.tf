variable "azure_subscription_id" {
  description = "Mgmt subscription GUID for IGMF sandbox (single-sub smoke test)."
  type        = string
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "environment" {
  type    = string
  default = "igmf"
}

variable "subscription_code" {
  type    = string
  default = "mgmt"
}

variable "hub01_id" {
  description = "Hub01 resource ID from environments/igmf/connectivity output hub01_id."
  type        = string
}

variable "hub01_firewall_private_ip" {
  description = "Hub01 AZFW private IP for AgentsSubnet default-to-firewall RT (connectivity output)."
  type        = string
}

variable "mandatory_tags" {
  type = object({
    costCentre             = string
    securityClassification = string
    resourceOwner          = string
    CMDB_AppID             = string
  })
}

# VERIFIED from legacy params/int/config.yml
variable "mgmt_address_space" {
  description = "Mgmt VNet/AgentsSubnet CIDR (net_mgmt_vnetAddressSpace)."
  type        = list(string)
  default     = ["10.170.139.192/26"]
}

variable "dns_servers" {
  description = "Azure DNS for IGMF — do NOT use bank 10.19.*"
  type        = list(string)
  default     = ["168.63.129.16"]
}

variable "mgmt_role_assignments" {
  description = "Extra subscription/RG RBAC for mgmt scope (map-driven). VM login / AAD group RBAC stays PowerShell."
  type = map(object({
    scope                = string
    role_definition_name = string
    principal_id         = string
  }))
  default = {}
}

variable "alert_action_group_email" {
  description = "Action group email receiver (IGMF sandbox)."
  type        = string
  default     = "dan.bowen@ignitemyfire.co.uk"
}

variable "enable_alert_uami" {
  description = "Create custom-log-alerts-msi and assign Reader on alert-scoped subscriptions."
  type        = bool
  default     = true
}

variable "alert_mult_subscription_ids" {
  description = "Multi-session lab subscriptions (key = short name used in alert/APR names, value = GUID)."
  type        = map(string)
  default     = {}
}

variable "alert_pers_subscription_ids" {
  description = "Personal lab subscriptions (key = short name, value = GUID)."
  type        = map(string)
  default     = {}
}

variable "alert_broker_subscription_ids" {
  description = "AVD broker (and any extra) subscriptions for Reader + APR + activity-log alerts."
  type        = map(string)
  default     = {}
}

variable "alert_fslogix_file_shares" {
  description = "FSLogix profile shares for capacity metric alerts (from labs STA outputs). Key arbitrary; exclude admin 999."
  type = map(object({
    storage_account_id = string
    share_name         = string
    quota_gb           = number
  }))
  default = {}
}

variable "apr_enabled" {
  description = "Enable alert processing rule suppression (legacy pipeline window)."
  type        = bool
  default     = false
}

variable "apr_effective_from" {
  description = "APR schedule start (ISO datetime) when apr_enabled is true."
  type        = string
  default     = null
}

variable "apr_effective_until" {
  description = "APR schedule end (ISO datetime) when apr_enabled is true."
  type        = string
  default     = null
}

variable "devops_vm_contributor_principal_id" {
  description = "Virtual Machine Contributor principal on mgmt subscription. Null skips. IGMF default null — do NOT use bank SP."
  type        = string
  default     = null
}
