output "hostpool_ids" {
  value = { for k, m in module.hostpool : k => m.hostpool_id }
}

output "hostpool_names" {
  value = { for k, m in module.hostpool : k => m.hostpool_name }
}

# Sensitive — for Get-PlacementAVD / token consumers
output "registration_tokens" {
  sensitive = true
  value     = { for k, m in module.hostpool : k => m.registration_token }
}

output "workspace_id" {
  value = module.workspace.workspace_id
}

output "keyvault_id" {
  value = module.keyvault.keyvault_id
}

output "gallery_name" {
  value = module.gallery.gallery_name
}

output "image_definition_names" {
  description = "Map of TF key → legacy image definition name (for Packer updates)."
  value       = { for k, v in local.image_definitions : k => v.legacy_name }
}

output "pers_hostpool_ids" {
  value = { for k, m in module.hostpool_pers : k => m.hostpool_id }
}

output "pers_registration_tokens" {
  sensitive = true
  value     = { for k, m in module.hostpool_pers : k => m.registration_token }
}
