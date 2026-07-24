output "pers_vnet_ids" {
  value = { for k, m in module.spoke_pers : k => m.vnet_id }
}

output "msh_vnet_ids" {
  value = { for k, m in module.spoke_msh : k => m.vnet_id }
}

output "fslogix_storage_account_name" {
  value = try(module.storage_fslogix[0].storage_account_name, null)
}
