output "law_id" {
  value = module.management.law_id
}

output "vnet_id" {
  value = module.spoke_mgmt.vnet_id
}

output "agents_subnet_id" {
  value = module.spoke_mgmt.subnet_ids["AgentsSubnet"]
}
