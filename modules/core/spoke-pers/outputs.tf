output "vnet_id" {
  description = "Resource ID of the spoke virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the spoke virtual network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet name -> resource ID. Consumed by AVD, Key Vault and storage modules."
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "nsg_ids" {
  description = "Map of subnet name -> network security group resource ID."
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}

output "hub_connection_id" {
  description = "Resource ID of the Hub01 virtual hub connection."
  value       = azurerm_virtual_hub_connection.hub01.id
}

output "route_table_id" {
  description = "Resource ID of the legacy default-to-firewall route table, or null when hub01_firewall_private_ip is empty."
  value       = try(azurerm_route_table.default_to_firewall[0].id, null)
}
