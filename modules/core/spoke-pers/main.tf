# ---------------------------------------------------------------------------
# Core — PERS Workload Spoke
#
# Deploys a PERS (personal desktop) workload spoke:
#   - Virtual Network + subnets
#   - Network Security Group per subnet (+ association)
#   - Optional default-to-firewall route table (legacy p_routeTables)
#   - Optional Network Watcher
#   - Hub connection to Hub01 (secured hub)
#
# When hub01_firewall_private_ip is set, associates a legacy-shaped UDR
# (0.0.0.0/0 -> VirtualAppliance, BGP prop disabled) to opted-in subnets.
# Contrast with modules/core/spoke-msh, which uses a three-rule dual-hub UDR.
#
# All resource names come from modules/naming.
# ---------------------------------------------------------------------------

module "vnet_name" {
  source = "../../naming"

  resource_type   = "virtual_network"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = var.name
  unique_id       = var.unique_id
}

module "nsg_names" {
  source   = "../../naming"
  for_each = var.subnets

  resource_type   = "network_security_group"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = "${var.name}-${each.key}"
}

module "route_table_name" {
  count  = var.hub01_firewall_private_ip != null ? 1 : 0
  source = "../../naming"

  resource_type   = "route_table"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = "${var.name}-default-to-firewall"
  unique_id       = var.unique_id
}

module "watcher_name" {
  source = "../../naming"

  resource_type   = "network_watcher"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = var.name
  unique_id       = var.unique_id
}

resource "azurerm_virtual_network" "this" {
  name                = module.vnet_name.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation == null ? [] : [each.value.delegation]
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = module.nsg_names[each.key].name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                         = security_rule.key
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      destination_port_range       = security_rule.value.destination_port_range
      source_port_ranges           = security_rule.value.source_port_ranges
      destination_port_ranges      = security_rule.value.destination_port_ranges
      source_address_prefix        = security_rule.value.source_address_prefix
      destination_address_prefix   = security_rule.value.destination_address_prefix
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefixes = security_rule.value.destination_address_prefixes
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

# ---------------------------------------------------------------------------
# Legacy default-to-firewall RT (p_routeTables) — optional when FW IP is set.
# ---------------------------------------------------------------------------

resource "azurerm_route_table" "default_to_firewall" {
  count = var.hub01_firewall_private_ip != null ? 1 : 0

  name                          = module.route_table_name[0].name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  bgp_route_propagation_enabled = false
  tags                          = var.tags

  route {
    name                   = "Route-To-Firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.hub01_firewall_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "default_to_firewall" {
  for_each = var.hub01_firewall_private_ip != null ? {
    for k, v in var.subnets : k => v if v.associate_route_table
  } : {}

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.default_to_firewall[0].id
}

resource "azurerm_network_watcher" "this" {
  count = var.create_network_watcher ? 1 : 0

  name                = module.watcher_name.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Connect the spoke VNet to Hub01.
resource "azurerm_virtual_hub_connection" "hub01" {
  # Intentional literal name (not via modules/naming): the connection name embeds
  # the spoke name + target hub for readability. "vhc" matches the TDA abbreviation.
  name                      = "vhc-${var.name}-hub01"
  virtual_hub_id            = var.hub01_id
  remote_virtual_network_id = azurerm_virtual_network.this.id
  internet_security_enabled = true
}
