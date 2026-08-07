# int × uksouth × connectivity — values only (stack code: environments/int/connectivity)
# Pipeline: -var-file=environments/region/uksouth/int.connectivity.tfvars
#
# Tags: resources use module.tags (platform keys auto-applied). Bank mandatory keys below
# are the platform standard for int/prd.

azure_subscription_id = "00000000-0000-0000-0000-000000000000" # TODO(deploy): int connectivity subscription GUID
location              = "uksouth"
environment           = "int"
subscription_code     = "conn"

# From config/vwan output vwan_id
virtual_wan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/REPLACE/providers/Microsoft.Network/virtualWans/REPLACE"

mandatory_tags = {
  costCentre             = "430034"
  securityClassification = "Limited"
  resourceOwner          = "VirtualTeam"
  CMDB_AppID             = "AL17611" # from legacy platform common_subscriptionTags
}

# Verbatim from legacy platform params/int/config.yml (address plan — still valid)
hub01_address_prefix = "10.170.245.0/24" # VERIFIED: net_hub_01_vnetAddressSpace
hub02_address_prefix = "10.170.246.0/24" # Accepted TF default (ex-PPD Hub01); distinct from prd Hub02 10.218.68.0/22

dns_servers = ["10.19.96.1", "10.19.97.1"] # VERIFIED: p_dnsServers

# Phased hub deploy (defaults true). Pipeline -var overrides these when hubSelection is set.
# enable_hub01 = true
# enable_hub02 = true

# expressroute_circuit_peering_id = "/subscriptions/.../peerings/AzurePrivatePeering"
