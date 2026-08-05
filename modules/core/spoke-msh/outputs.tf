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

output "route_table_id" {
  description = "Resource ID of the three-rule UDR route table."
  value       = azurerm_route_table.this.id
}

output "hub01_connection_id" {
  description = "Resource ID of the Hub01 virtual hub connection."
  value       = azurerm_virtual_hub_connection.hub01.id
}

output "hub02_connection_id" {
  description = "Always null — Azure allows one hub connection per VNet; Hub02 VPN must use hub-to-hub via Hub01."
  value       = null
}
