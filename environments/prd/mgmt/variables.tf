variable "azure_subscription_id" {
  description = "Mgmt subscription GUID for prod."
  type        = string
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "subscription_code" {
  type    = string
  default = "mgmt"
}

variable "hub01_id" {
  description = "Hub01 resource ID from environments/prd/connectivity output hub01_id."
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

# VERIFIED from legacy params/prd/config.yml
variable "mgmt_address_space" {
  description = "Mgmt VNet/AgentsSubnet CIDR (net_mgmt_vnetAddressSpace)."
  type        = list(string)
  default     = ["10.170.241.64/26"]
}

variable "dns_servers" {
  type    = list(string)
  default = ["10.19.96.1", "10.19.97.1"]
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
  description = "Legacy acg-DevicesLab email receiver."
  type        = string
  default     = "GRPG882932@nalloydsbanking.com"
}

variable "enable_alert_uami" {
  description = "Create custom-log-alerts-msi (Reader on lab subs assigned when alert rules land)."
  type        = bool
  default     = true
}

variable "devops_vm_contributor_principal_id" {
  description = "Legacy SP-P-VDI-ADA-VMC-01 object ID (Virtual Machine Contributor on mgmt subscription). Null skips."
  type        = string
  # legacy/platform/.../params/prd/01/mgmt/params-access.json
  default     = "e40ed67b-b191-4562-b9b1-130f8d389d65"
}
