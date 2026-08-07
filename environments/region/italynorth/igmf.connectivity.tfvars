# igmf × italynorth × connectivity — values only (stack code: environments/igmf/connectivity)
# Pipeline: -var-file=environments/region/italynorth/igmf.connectivity.tfvars
# Placeholder regional lab — hub CIDRs blank until set.

azure_subscription_id = "cc1ccb8d-18a1-4dca-aa5a-54607876c990" # IGMF sandbox (confirm if regional sub differs)
location              = "italynorth"
environment           = "igmf"
subscription_code     = "conn"

virtual_wan_id = "/subscriptions/cc1ccb8d-18a1-4dca-aa5a-54607876c990/resourceGroups/REPLACE/providers/Microsoft.Network/virtualWans/REPLACE"

mandatory_tags = {
  costCentre             = "IGMF-SANDBOX"
  securityClassification = "Limited"
  resourceOwner          = "dan.bowen@ignitemyfire.co.uk"
  CMDB_AppID             = "IGMF001"
}

hub01_address_prefix = "" # TODO(deploy): italynorth Hub01 CIDR
hub02_address_prefix = "" # TODO(deploy): italynorth Hub02 CIDR

dns_servers = ["168.63.129.16"] # Azure DNS
