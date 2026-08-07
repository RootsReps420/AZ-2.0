# int × spaincentral × connectivity — values only (stack code: environments/int/connectivity)
# Pipeline: -var-file=environments/region/spaincentral/int.connectivity.tfvars
#
# Naming/tags: environment, location, subscription_code feed modules/naming + modules/tags.
# Hub CIDRs blank until regional address plan is set (do not inherit uksouth defaults).

azure_subscription_id = "00000000-0000-0000-0000-000000000000" # TODO(deploy): int connectivity subscription GUID (spaincentral)
location              = "spaincentral"
environment           = "int"
subscription_code     = "conn"

virtual_wan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/REPLACE/providers/Microsoft.Network/virtualWans/REPLACE"

mandatory_tags = {
  costCentre             = "430034"
  securityClassification = "Limited"
  resourceOwner          = "VirtualTeam"
  CMDB_AppID             = "AL17611"
}

hub01_address_prefix = "" # TODO(deploy): spaincentral Hub01 CIDR
hub02_address_prefix = "" # TODO(deploy): spaincentral Hub02 CIDR

dns_servers = ["10.19.96.1", "10.19.97.1"]
