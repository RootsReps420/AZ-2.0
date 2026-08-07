# TODO(deploy): connectivity/hub subscription GUID for int.
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
  description = "Environment code (int = DT)."
  type        = string
  default     = "int"
}

variable "subscription_code" {
  description = "Naming segment for connectivity resources."
  type        = string
  default     = "conn"
}

# Sourced from environments/vwan output vwan_id.
variable "virtual_wan_id" {
  description = "Resource ID of the shared Virtual WAN."
  type        = string
}

variable "mandatory_tags" {
  description = "Mandatory bank tags (see modules/tags)."
  type = object({
    costCentre             = string
    securityClassification = string
    resourceOwner          = string
    CMDB_AppID             = string
  })
}

# Address plan from legacy platform params/int/config.yml (verbatim for Hub01).
# Virtual hub uses /23 or /24 — classic AzureFirewallSubnet / GatewaySubnet are
# NOT recreated as VNet subnets under vWAN (AZFW_Hub + ER GW are hub features).
#
# Hub01 INT: net_hub_01_vnetAddressSpace = 10.170.245.0/24  (VERIFIED)
# Hub02: new unsecured hub — NOT in classic estate. 10.170.246.0/24 was PPD Hub01
#   (ppd dropped); unused in int allocations (within net_superNetCidr 10.170.128.0/17).
#   Must stay distinct from prd Hub02 (Azure 2.0: 10.218.68.0/22). See docs/address-plan-hubs.md.
variable "hub01_address_prefix" {
  description = "Hub01 (secured) virtual hub address prefix. Legacy net_hub_01_vnetAddressSpace."
  type        = string
  default     = "10.170.245.0/24"
}

variable "hub02_address_prefix" {
  description = "Hub02 (unsecured) virtual hub address prefix. Accepted TF default (ex-PPD Hub01); distinct from prd Hub02 10.218.68.0/22 (see docs/address-plan-hubs.md)."
  type        = string
  default     = "10.170.246.0/24"
}

variable "dns_servers" {
  description = "Corporate DNS servers (legacy p_dnsServers)."
  type        = list(string)
  default     = ["10.19.96.1", "10.19.97.1"]
}

variable "expressroute_circuit_peering_id" {
  description = "Optional ER circuit private peering ID. Null = gateway only."
  type        = string
  default     = null
}

# Pipeline / phased deploy: hubSelection maps to these. Defaults true = deploy both
# (current behaviour). Narrowing a flag from true→false plans destroy of that hub.
variable "enable_hub01" {
  description = "Deploy Hub01 secured (firewall policy + AZFW + Routing Intent + ER GW)."
  type        = bool
  default     = true
}

variable "enable_hub02" {
  description = "Deploy Hub02 unsecured (virtual hub + VPN gateway)."
  type        = bool
  default     = true
}
