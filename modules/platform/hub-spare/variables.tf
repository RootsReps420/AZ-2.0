variable "name" {
  description = "Descriptor for the spare hub resources (e.g. \"hub03\"). Used as the description segment when generating names via modules/naming."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group into which the hub is deployed."
  type        = string
}

variable "location" {
  description = "Azure region for all resources in this module."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming inputs — passed through to modules/naming
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription/landing-zone segment used to name the hub (e.g. \"conn\")."
  type        = string
}

variable "environment" {
  description = "Environment segment used to name the hub (e.g. \"prd\")."
  type        = string
}

variable "unique_id" {
  description = "Optional uniqueness/instance suffix used when naming the hub (e.g. \"03\"). Omit when name already carries the instance (e.g. \"hub03\")."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Hub
# ---------------------------------------------------------------------------

variable "virtual_wan_id" {
  description = "Resource ID of the Virtual WAN this hub is attached to."
  type        = string
}

variable "address_prefix" {
  description = "Address space of the virtual hub in CIDR notation. Azure minimum is /24; recommend /23 or larger. Azure Firewall in a hub requires /22 for max scale. Bank Azure 2.0 hubs use /22."
  type        = string

  validation {
    condition     = can(cidrhost(var.address_prefix, 0))
    error_message = "address_prefix must be a valid CIDR block (e.g. \"10.218.72.0/22\")."
  }
}

variable "hub_routing_preference" {
  description = "Routing preference for the virtual hub. One of: ExpressRoute, VpnGateway, ASPath. Default ExpressRoute (Azure default / private-path oriented). Unlike Hub02 there is no VPN gateway on this hub, so VpnGateway is not the natural default."
  type        = string
  default     = "ExpressRoute"

  validation {
    condition     = contains(["ExpressRoute", "VpnGateway", "ASPath"], var.hub_routing_preference)
    error_message = "hub_routing_preference must be one of: ExpressRoute, VpnGateway, ASPath."
  }
}

variable "tags" {
  description = "Merged tag map (output of modules/tags) applied to the hub."
  type        = map(string)
  default     = {}
}
