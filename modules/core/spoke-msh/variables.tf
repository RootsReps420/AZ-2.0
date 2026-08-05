variable "name" {
  description = "Descriptor for the spoke (e.g. \"msh-fin\"). Used as the description segment when generating names via modules/naming."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group into which the spoke resources are deployed."
  type        = string
}

variable "location" {
  description = "Azure region for all resources in this module."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming inputs
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription/landing-zone segment used to name the spoke resources."
  type        = string
}

variable "environment" {
  description = "Environment segment used to name the spoke resources (e.g. \"dev\", \"prod\")."
  type        = string
}

variable "unique_id" {
  description = "Optional uniqueness/instance suffix used when naming the spoke resources."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------

variable "address_space" {
  description = "Address space of the spoke virtual network (list of CIDRs)."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "address_space must contain at least one CIDR."
  }
}

variable "dns_servers" {
  description = "Custom DNS servers for the VNet. Empty list uses Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = <<-EOT
    Subnets keyed by name. Each subnet gets an NSG (+ association). Set
    associate_route_table = true (default) to apply the three-rule UDR to it.
  EOT
  type = map(object({
    address_prefixes      = list(string)
    service_endpoints     = optional(list(string), [])
    associate_route_table = optional(bool, true)
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = list(string)
    }))
    security_rules = optional(map(object({
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range            = optional(string)
      destination_port_range       = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      destination_address_prefix   = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefixes = optional(list(string))
    })), {})
  }))
}

# ---------------------------------------------------------------------------
# Dual-hub connectivity + UDR
# ---------------------------------------------------------------------------

variable "hub01_id" {
  description = "Resource ID of Hub01 (secured hub) for IP reachability. Output hub_id from modules/platform/hub-secured."
  type        = string
}

variable "hub02_id" {
  description = <<-EOT
    Resource ID of Hub02 (unsecured hub). Kept for API compatibility and future
    hub-to-hub / UDR wiring. Not used for a second virtual_hub_connection —
    Azure allows only one hub per VNet (see main.tf).
  EOT
  type        = string
}

variable "hub01_firewall_private_ip" {
  description = "Private IP of the Hub01 Azure Firewall. Service-tag and RFC1918 traffic is routed here. Output firewall_private_ip from modules/platform/hub-secured."
  type        = string
}

variable "default_route_next_hop_type" {
  description = "Next hop type for the 0.0.0.0/0 route (internet egress via Hub02 VPN gateway). Typically VirtualNetworkGateway."
  type        = string
  default     = "VirtualNetworkGateway"

  validation {
    condition     = contains(["VirtualNetworkGateway", "VirtualAppliance", "Internet", "None"], var.default_route_next_hop_type)
    error_message = "default_route_next_hop_type must be one of: VirtualNetworkGateway, VirtualAppliance, Internet, None."
  }
}

variable "rfc1918_prefixes" {
  description = "RFC1918 private ranges routed to the Hub01 firewall."
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "service_tag_routes" {
  description = "Service tags routed to the Hub01 firewall (used as UDR address prefixes)."
  type        = list(string)
  default     = ["AzureCloud"]
}

variable "create_network_watcher" {
  description = "When true, create a Network Watcher in this resource group. Azure permits one per region per subscription."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Merged tag map (output of modules/tags) applied to all resources."
  type        = map(string)
  default     = {}
}
