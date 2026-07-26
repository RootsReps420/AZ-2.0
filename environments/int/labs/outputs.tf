output "pers_vnet_ids" {
  value = { for k, m in module.spoke_pers : k => m.vnet_id }
}

output "msh_vnet_ids" {
  value = { for k, m in module.spoke_msh : k => m.vnet_id }
}

output "fslogix_storage_account_names" {
  description = "FSLogix storage account names keyed by lab-bu (e.g. 01a-001)."
  value       = { for k, m in module.storage_fslogix : k => m.storage_account_name }
}

output "lab_keyvault_mult_ids" {
  value = { for k, m in module.keyvault_mult : k => m.keyvault_id }
}

output "lab_keyvault_pers_ids" {
  value = { for k, m in module.keyvault_pers : k => m.keyvault_id }
}

output "pers_blob_storage_account_names" {
  value = { for k, m in module.storage_pers_blob : k => m.storage_account_name }
}

output "fslogix_cmk_identity_ids" {
  value = { for k, m in azurerm_user_assigned_identity.fslogix : k => m.id }
}
