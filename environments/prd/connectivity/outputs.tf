output "resource_group_name" {
  description = "Connectivity resource group name."
  value       = azurerm_resource_group.connectivity.name
}

output "firewall_policy_id" {
  description = "Baseline firewall policy ID attached to Hub01. Null when enable_hub01 is false."
  value       = try(module.firewall_policy[0].policy_id, null)
}

output "hub01_id" {
  description = "Secured virtual hub (Hub01) resource ID. Null when enable_hub01 is false."
  value       = try(module.hub_secured[0].hub_id, null)
}

output "hub01_firewall_private_ip" {
  description = "Hub01 Azure Firewall private IP (for spoke UDRs). Null when enable_hub01 is false."
  value       = try(module.hub_secured[0].firewall_private_ip, null)
}

output "hub02_id" {
  description = "Unsecured virtual hub (Hub02) resource ID. Null when enable_hub02 is false."
  value       = try(module.hub_unsecured[0].hub_id, null)
}

# SPARE (not deployed): uncomment with module.hub_spare in main.tf when Hub03 is enabled.
# output "hub03_id" {
#   description = "Spare bare virtual hub (Hub03) resource ID. No spoke consumers yet."
#   value       = module.hub_spare.hub_id
# }
