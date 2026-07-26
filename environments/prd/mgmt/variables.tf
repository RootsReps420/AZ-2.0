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
  description = "Subscription/RG RBAC for mgmt scope. Principals from tfvars (Phase D access.bicep port). VM/AAD RBAC stays PS."
  type = map(object({
    scope                = string
    role_definition_name = string
    principal_id         = string
  }))
  default = {}
}
