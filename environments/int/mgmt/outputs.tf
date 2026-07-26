output "law_id" {
  value = module.management.law_id
}

output "vnet_id" {
  value = module.spoke_mgmt.vnet_id
}

output "agents_subnet_id" {
  value = module.spoke_mgmt.subnet_ids["AgentsSubnet"]
}

output "alert_action_group_ids" {
  value = module.management.action_group_ids
}

output "alert_uami_principal_id" {
  value = try(azurerm_user_assigned_identity.alert_logs[0].principal_id, null)
}

output "alert_uami_id" {
  value = try(azurerm_user_assigned_identity.alert_logs[0].id, null)
}
