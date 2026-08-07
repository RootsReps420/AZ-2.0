module "tags" {
  source = "../.."

  workload    = "platform"
  environment = "int"
  region      = "uksouth"

  mandatory = {
    costCentre             = "430034"
    securityClassification = "Limited"
    resourceOwner          = "VirtualTeam"
    CMDB_AppID             = "AL17611"
  }
}

# Pass to resources: tags = module.tags.tags
