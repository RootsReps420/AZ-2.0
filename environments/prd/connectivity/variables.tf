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

# Azure 2.0 hub IP plan (Production): parent 10.218.64.0/20 as three /22 hubs.
# Hub01 secured / Hub02 unsecured deploy today. Hub03 spare CIDR is reserved in
# code only (module hub_spare commented out) until a region needs it.
# Distinct from int hubs (10.170.245/246) on the shared vWAN.
# Do NOT use 10.170.248.0/24 (PERS 01l /21).
# Supersedes classic Azure 1.0 Hub01 10.170.247.0/24 and interim Hub02 10.170.244.0/24.
variable "hub01_address_prefix" {
  description = "Hub01 (secured) virtual hub address prefix. Azure 2.0 Production hub 1."
  type        = string
  default     = "10.218.64.0/22"
}

variable "hub02_address_prefix" {
  description = "Hub02 (unsecured) virtual hub address prefix. Azure 2.0 Production hub 2. Do NOT use 10.170.248.0/24 (pers 01l)."
  type        = string
  default     = "10.218.68.0/22"
}

variable "hub03_address_prefix" {
  description = "Hub03 (spare / bare) reserved virtual hub address prefix. SPARE — not deployed until module hub_spare is uncommented in main.tf. Region-agnostic when enabled."
  type        = string
  default     = "10.218.72.0/22"
}

variable "dns_servers" {
  type    = list(string)
  default = ["10.19.96.1", "10.19.97.1"]
}

variable "expressroute_circuit_peering_id" {
  type    = string
  default = null
}
