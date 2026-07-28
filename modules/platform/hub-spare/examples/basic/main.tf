# Basic example — deploy Hub03 (spare / bare) attached to an existing Virtual WAN.

module "hub_spare" {
  source = "../.."

  name                = "hub03"
  resource_group_name = "rg-conn-hub03-dev"
  location            = "uksouth"
  subscription_id     = "conn"
  environment         = "dev"
  unique_id           = "03"

  virtual_wan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-conn-global-prod/providers/Microsoft.Network/virtualWans/uks-conn-vwn-vdi-01" # EXAMPLE ONLY: real vWAN id
  address_prefix = "10.218.72.0/22"

  tags = {
    "managed-by" = "terraform"
    environment  = "dev"
    workload     = "vdi-platform"
    repo         = "vdi-terraform"
  }
}

output "hub_id" {
  value = module.hub_spare.hub_id
}
