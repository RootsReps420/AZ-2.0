# TODO(deploy): IGMF sandbox connectivity subscription GUID (often same as _global).
variable "azure_subscription_id" {
  description = "Azure subscription GUID for the connectivity scope (hubs, firewall, VPN)."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "uksouth"
}

variable "environment" {
  description = "Environment code (igmf = disconnected sandbox tenant)."
  type        = string
  default     = "igmf"
}

variable "subscription_code" {
  description = "Naming segment for connectivity resources."
  type        = string
  default     = "conn"
}

# Sourced from environments/_global output vwan_id (state key igmf/_global.tfstate).
variable "virtual_wan_id" {
  description = "Resource ID of the shared Virtual WAN."
  type        = string
}

variable "mandatory_tags" {
  description = "Mandatory tag keys (see modules/tags). Use sandbox placeholders in IGMF."
  type = object({
    costCentre             = string
    securityClassification = string
    resourceOwner          = string
    CMDB_AppID             = string
  })
}

# Hub CIDRs: reuse int defaults — fine in an isolated tenant (no bank vWAN collision).
variable "hub01_address_prefix" {
  description = "Hub01 (secured) virtual hub address prefix."
  type        = string
  default     = "10.170.245.0/24"
}

variable "hub02_address_prefix" {
  description = "Hub02 (unsecured) virtual hub address prefix."
  type        = string
  default     = "10.170.246.0/24"
}

variable "dns_servers" {
  description = "DNS servers for firewall policy DNS proxy. IGMF uses Azure DNS — not bank 10.19.*"
  type        = list(string)
  default     = ["168.63.129.16"]
}

variable "expressroute_circuit_peering_id" {
  description = "Optional ER circuit private peering ID. Null = gateway only (typical for IGMF)."
  type        = string
  default     = null
}
