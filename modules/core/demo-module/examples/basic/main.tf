# Basic example - wires modules/tags and the scaffolded module.
# From this directory: terraform init -backend=false && terraform validate
# (validate may fail until TODO(deploy) resources are filled in.)

module "tags" {
  source = "../../../../tags"

  workload    = "vdi-platform"
  environment = "dev"
  region      = "uksouth"

  mandatory = {
    costCentre             = "CC-0000"
    securityClassification = "Internal"
    resourceOwner          = "platform@example.com"
    CMDB_AppID             = "APP-00000"
  }
}

module "demo_module" {
  source = "../.."

  resource_group_name = "rg-example-dev"
  location            = "uksouth"
  environment         = "dev"
  subscription_id     = "vdi"
  description         = "example"
  unique_id           = "01"

  tags = module.tags.tags
}

# output "id" {
#   value = module.demo_module.id
# }