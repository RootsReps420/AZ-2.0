# TODO(deploy): supply the real subscription GUID for this environment via tfvars.
variable "azure_subscription_id" {
  description = "Azure subscription GUID this environment deploys into."
  type        = string
}

variable "location" {
  description = "Azure region for this environment root. Change this (or use a different region root) to deploy elsewhere — all naming is region-driven."
  type        = string
  default     = "uksouth"
}

variable "environment" {
  description = "Environment segment used in names and tags."
  type        = string
  default     = "dev"
}

variable "subscription_code_conn" {
  description = "Naming segment for connectivity resources (hubs, firewall, management)."
  type        = string
  default     = "conn"
}

variable "subscription_code_vdi" {
  description = "Naming segment for VDI workload resources (spokes, key vault, storage, AVD, images)."
  type        = string
  default     = "vdi"
}

# TODO(deploy): set to the config/vwan output `vwan_id` for this tenant.
variable "virtual_wan_id" {
  description = "Resource ID of the global Virtual WAN. Sourced from the config/vwan workspace output vwan_id."
  type        = string
}

# TODO(deploy): supply real values via tfvars (costCentre, securityClassification, resourceOwner, CMDB_AppID).
variable "mandatory_tags" {
  description = "Mandatory bank tags applied to all resources (see modules/tags)."
  type = object({
    costCentre             = string
    securityClassification = string
    resourceOwner          = string
    CMDB_AppID             = string
  })
}

# ---------------------------------------------------------------------------
# Network address plan
# ---------------------------------------------------------------------------

variable "hub01_address_prefix" {
  description = "Address prefix for Hub01 (secured hub)."
  type        = string
  default     = "10.0.0.0/23"
}

variable "hub02_address_prefix" {
  description = "Address prefix for Hub02 (unsecured hub)."
  type        = string
  default     = "10.1.0.0/23"
}

variable "pers_spoke_address_space" {
  description = "Address space for the PERS lab spoke."
  type        = list(string)
  default     = ["10.10.0.0/22"]
}

variable "msh_spoke_address_space" {
  description = "Address space for the MSH lab spoke."
  type        = list(string)
  default     = ["10.20.0.0/22"]
}

variable "expressroute_circuit_peering_id" {
  description = "Optional ExpressRoute circuit private peering ID to connect Hub01's ER gateway. Null creates the gateway without a circuit connection."
  type        = string
  default     = null
}
