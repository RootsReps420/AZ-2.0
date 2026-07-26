output "pers_vnet_ids" {
  value = { for k, m in module.spoke_pers : k => m.vnet_id }
}

output "msh_vnet_ids" {
  value = { for k, m in module.spoke_msh : k => m.vnet_id }
}

output "fslogix_storage_account_names" {
  description = "FSLogix STA names keyed by lab-bu (e.g. 01a-001)."
  value       = { for k, m in module.storage_fslogix : k => m.storage_account_name }
}
