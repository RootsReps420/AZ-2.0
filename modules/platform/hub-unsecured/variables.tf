variable "name" {
  description = "Descriptor for the unsecured hub resources (e.g. \"hub02\"). Used as the description segment when generating names via modules/naming."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group into which the hub resources are deployed."
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
  description = "Subscription/landing-zone segment used to name the hub resources (e.g. \"conn\")."
  type        = string
}

variable "environment" {
  description = "Environment segment used to name the hub resources (e.g. \"dev\", \"prod\")."
  type        = string
}

variable "unique_id" {
  description = "Optional uniqueness/instance suffix used when naming the hub resources (e.g. \"02\")."
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
  description = "Address space of the virtual hub in CIDR notation. Azure minimum is /24; recommend /23 or larger. Bank Azure 2.0 hubs use /22."
  type        = string

  validation {
    condition     = can(cidrhost(var.address_prefix, 0))
    error_message = "address_prefix must be a valid CIDR block (e.g. \"10.218.68.0/22\")."
  }
}

variable "hub_routing_preference" {
  description = "Routing preference for the virtual hub. One of: ExpressRoute, VpnGateway, ASPath."
  type        = string
  default     = "VpnGateway"

  validation {
    condition     = contains(["ExpressRoute", "VpnGateway", "ASPath"], var.hub_routing_preference)
    error_message = "hub_routing_preference must be one of: ExpressRoute, VpnGateway, ASPath."
  }
}

# ---------------------------------------------------------------------------
# VPN Gateway
# ---------------------------------------------------------------------------

variable "vpn" {
  description = <<-EOT
    VPN Gateway configuration.
      scale_unit         : Number of scale units for the gateway (>= 1). Each unit is 500 Mbps aggregate throughput.
      routing_preference : "Microsoft Network" or "Internet".
      bgp_settings       : (Optional) BGP settings { asn, peer_weight }. Null disables BGP.
  EOT
  type = object({
    scale_unit         = optional(number, 1)
    routing_preference = optional(string, "Microsoft Network")
    bgp_settings = optional(object({
      asn         = number
      peer_weight = number
    }))
  })
  default = {}

  validation {
    condition     = var.vpn.scale_unit >= 1
    error_message = "vpn.scale_unit must be at least 1."
  }

  validation {
    condition     = contains(["Microsoft Network", "Internet"], var.vpn.routing_preference)
    error_message = "vpn.routing_preference must be \"Microsoft Network\" or \"Internet\"."
  }
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace to send VPN gateway diagnostics to. When null, no diagnostic setting is created."
  type        = string
  default     = null
}

variable "tags" {
  description = "Merged tag map (output of modules/tags) applied to all resources."
  type        = map(string)
  default     = {}
}
