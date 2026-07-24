variable "name" {
  description = "Descriptor for the spoke (e.g. \"pers-lab01\"). Used as the description segment when generating names via modules/naming."
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
  description = "Environment segment used to name the spoke resources (e.g. \"int\", \"prd\")."
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
    Subnets keyed by name. Each subnet gets an NSG (with the given security rules)
    and an NSG association. security_rules are keyed by rule name.
    When hub01_firewall_private_ip is set, associate_route_table associates the
    legacy default-to-firewall route table.
  EOT
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
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

variable "hub01_id" {
  description = "Resource ID of Hub01 (secured hub) that this spoke connects to. Output hub_id from modules/platform/hub-secured."
  type        = string
}

variable "hub01_firewall_private_ip" {
  description = <<-EOT
    Private IP of the Hub01 Azure Firewall. When non-empty, creates the legacy
    default-to-firewall route table (0.0.0.0/0 -> VirtualAppliance, BGP
    propagation disabled) and associates it to subnets with
    associate_route_table = true. Leave empty to skip the RT.
  EOT
  type    = string
  default = ""
}

variable "create_network_watcher" {
  description = "When true, create a Network Watcher in this resource group. Note: Azure permits one Network Watcher per region per subscription."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Merged tag map (output of modules/tags) applied to all resources."
  type        = map(string)
  default     = {}
}
