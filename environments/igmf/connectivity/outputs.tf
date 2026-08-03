output "resource_group_name" {
  description = "Connectivity resource group name."
  value       = azurerm_resource_group.connectivity.name
}

output "firewall_policy_id" {
  description = "Baseline firewall policy ID attached to Hub01."
  value       = module.firewall_policy.policy_id
}

output "hub01_id" {
  description = "Secured virtual hub (Hub01) resource ID."
  value       = module.hub_secured.hub_id
}

output "hub01_firewall_private_ip" {
  description = "Hub01 Azure Firewall private IP (for spoke UDRs)."
  value       = module.hub_secured.firewall_private_ip
}

output "hub02_id" {
  description = "Unsecured virtual hub (Hub02) resource ID."
  value       = module.hub_unsecured.hub_id
}
