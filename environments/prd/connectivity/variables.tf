variable "azure_subscription_id" {
  description = "Azure subscription GUID for the connectivity scope (hubs, firewall, VPN)."
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
  default = "conn"
}

variable "virtual_wan_id" {
  description = "Resource ID of the shared Virtual WAN."
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

# Legacy platform params/prd/config.yml
# Hub01 PROD: net_hub_01_vnetAddressSpace = 10.170.247.0/24  (VERIFIED)
# Hub02: new — MUST NOT use 10.170.248.0/24 (collides with net_lab_core_pers_01l
#   10.170.248.0/21). Candidate 10.170.244.0/24 (unused in legacy; distinct from
#   INT Hub02 10.170.246.0/24). Do NOT reuse 246 for both envs. Network sign-off required.
variable "hub01_address_prefix" {
  type    = string
  default = "10.170.247.0/24"
}

variable "hub02_address_prefix" {
  description = "Hub02 (unsecured) virtual hub address prefix. Accepted TF default. Do NOT use 10.170.248.0/24 (pers 01l) or 10.170.246.0/24 (INT Hub02)."
  type        = string
  default     = "10.170.244.0/24"
}

variable "dns_servers" {
  type    = list(string)
  default = ["10.19.96.1", "10.19.97.1"]
}

variable "expressroute_circuit_peering_id" {
  type    = string
  default = null
}
