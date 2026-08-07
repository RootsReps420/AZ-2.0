output "vwan_id" {
  description = "Resource ID of the global Virtual WAN. Referenced by per-region hub deployments."
  value       = module.vwan.vwan_id
}

output "vwan_name" {
  description = "Name of the global Virtual WAN."
  value       = module.vwan.vwan_name
}

output "global_resource_group_name" {
  description = "Name of the resource group holding the global resources."
  value       = azurerm_resource_group.global.name
}
