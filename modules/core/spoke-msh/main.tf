# ---------------------------------------------------------------------------
# Core — MSH Workload Spoke  (SENIOR-ENGINEER REVIEW REQUIRED)
#
# Deploys an MSH (multi-session host) workload spoke. More complex than
# spoke-pers because it connects to BOTH hubs and overrides Hub01 Routing Intent
# with an explicit route table:
#
#   - Virtual Network + subnets + NSG per subnet
#   - Route table with the three-rule UDR:
#       0.0.0.0/0     -> Hub02 VPN Gateway  (internet via Palo Alto Proxy)
#       Service Tags  -> Hub01 Firewall Private IP
#       RFC1918       -> Hub01 Firewall Private IP
#   - Hub01 connection (IP reachability; internet security disabled — the UDR
#     governs egress) and Hub02 connection (remote gateway transit for TSA VPN & Several IPSec Tunnels built out.)
#   - Optional Network Watcher
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
  source = "../../naming"

  resource_type   = "route_table"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = var.name
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
# Route table — the three-rule UDR that overrides Hub01 Routing Intent.
# ---------------------------------------------------------------------------

locals {
  # RFC1918 + service-tag prefixes routed to the Hub01 firewall.
  firewall_routes = merge(
    { for cidr in var.rfc1918_prefixes : "rfc1918-${replace(replace(cidr, "/", "-"), ".", "_")}" => cidr },
    { for tag in var.service_tag_routes : "servicetag-${lower(tag)}" => tag },
  )
}

resource "azurerm_route_table" "this" {
  name                = module.route_table_name.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  # Rule 1: default route -> Hub02 VPN Gateway (internet via Palo Alto Proxy).
  # PENDING(LLD): SENIOR REVIEW - in a vWAN topology the spoke reaches the hub via
  # the hub connection (BGP), not a local VNet gateway. Confirm that a static
  # 0.0.0.0/0 -> VirtualNetworkGateway UDR routes as intended here, or whether the
  # next hop should be the Hub02 VPN gateway's private IP (VirtualAppliance).
  route {
    name           = "default-to-vpn"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = var.default_route_next_hop_type
  }

  # Rules 2 & 3: Service Tags + RFC1918 -> Hub01 firewall private IP.
  dynamic "route" {
    for_each = local.firewall_routes
    content {
      name                   = route.key
      address_prefix         = route.value
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.hub01_firewall_private_ip
    }
  }
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for k, v in var.subnets : k => v if v.associate_route_table }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this.id
}

resource "azurerm_network_watcher" "this" {
  count = var.create_network_watcher ? 1 : 0

  name                = module.watcher_name.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# Hub connection (Hub01 only).
# ---------------------------------------------------------------------------
#
# Azure Virtual WAN hard limit: a VNet can connect to only ONE virtual hub
# (error VirtualNetworkIsAlreadyConnectedToAnotherHub). Dual Hub01+Hub02
# connections on the same MSH VNet are invalid — confirmed in IGMF apply.
# https://learn.microsoft.com/azure/virtual-wan/howto-connect-vnet-hub
#
# MSH still uses the three-rule UDR (internet → Hub02 VPN next-hop type;
# RFC1918/AzureCloud → Hub01 AZFW). Reaching Hub02 VPN once the peer exists
# must be via Hub01 connection + vWAN hub-to-hub routing — not a second
# hubVirtualNetworkConnection. var.hub02_id retained for callers / future wiring.

# Hub01 — spoke attachment. internet_security_enabled=false so the UDR (not
# Hub01 Routing Intent) governs egress.
resource "azurerm_virtual_hub_connection" "hub01" {
  # Intentional literal name (not via modules/naming): embeds spoke + target hub.
  # "vhc" matches the TDA abbreviation.
  name                      = "vhc-${var.name}-hub01"
  virtual_hub_id            = var.hub01_id
  remote_virtual_network_id = azurerm_virtual_network.this.id
  internet_security_enabled = false
}
