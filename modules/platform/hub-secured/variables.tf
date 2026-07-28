variable "name" {
  description = "Descriptor for the secured hub resources (e.g. \"hub01\"). Used as the description segment when generating names via modules/naming."
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
  description = "Optional uniqueness/instance suffix used when naming the hub resources (e.g. \"01\")."
  type        = string
  default     = ""
}

variable "virtual_wan_id" {
  description = "Resource ID of the Virtual WAN this hub is attached to."
  type        = string
}

variable "address_prefix" {
  description = "Address space of the virtual hub in CIDR notation. Azure minimum is /24; recommend /23 or larger. Azure Firewall in a hub requires /22 for max scale. Bank Azure 2.0 hubs use /22."
  type        = string

  validation {
    condition     = can(cidrhost(var.address_prefix, 0))
    error_message = "address_prefix must be a valid CIDR block (e.g. \"10.218.64.0/22\")."
  }
}

variable "hub_routing_preference" {
  description = "Routing preference for the virtual hub. One of: ExpressRoute, VpnGateway, ASPath."
  type        = string
  default     = "ExpressRoute"

  validation {
    condition     = contains(["ExpressRoute", "VpnGateway", "ASPath"], var.hub_routing_preference)
    error_message = "hub_routing_preference must be one of: ExpressRoute, VpnGateway, ASPath."
  }
}

# ---------------------------------------------------------------------------
# Azure Firewall
# ---------------------------------------------------------------------------

variable "firewall_policy_id" {
  description = "Resource ID of the Firewall Policy applied to the hub Azure Firewall."
  type        = string
}

variable "firewall_sku_tier" {
  description = "SKU tier of the hub Azure Firewall. One of: Standard, Premium."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_sku_tier)
    error_message = "firewall_sku_tier must be either Standard or Premium."
  }
}

variable "firewall_public_ip_count" {
  description = "Number of public IP addresses to provision for the hub Azure Firewall. Azure auto-creates these (Microsoft.Network/publicIPAddresses) as part of the AZFW_Hub deployment."
  type        = number
  default     = 1

  validation {
    condition     = var.firewall_public_ip_count >= 1
    error_message = "firewall_public_ip_count must be at least 1."
  }
}

variable "firewall_zones" {
  description = "Availability zones for the hub Azure Firewall. Empty list means no zone redundancy."
  type        = list(string)
  default     = ["1", "2", "3"]
}

# ---------------------------------------------------------------------------
# ExpressRoute
# ---------------------------------------------------------------------------

variable "express_route" {
  description = <<-EOT
    ExpressRoute Gateway and circuit connection details.
      scale_units          : Number of scale units for the ER gateway (1-10).
      circuit_peering_id    : (Optional) Resource ID of the ExpressRoute circuit private peering to connect. When null, only the gateway is created (no circuit connection).
      routing_weight        : (Optional) Routing weight for the ER connection (0-32000).
      authorization_key     : (Optional) Authorization key when the circuit lives in another subscription/tenant.
  EOT
  type = object({
    scale_units        = optional(number, 1)
    circuit_peering_id = optional(string)
    routing_weight     = optional(number, 0)
    authorization_key  = optional(string)
  })

  validation {
    condition     = var.express_route.scale_units >= 1 && var.express_route.scale_units <= 10
    error_message = "express_route.scale_units must be between 1 and 10."
  }
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace (output law_id from modules/platform/management) to send firewall diagnostics to. When null, no diagnostic setting is created."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
