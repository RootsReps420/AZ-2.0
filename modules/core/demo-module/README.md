# modules/core/demo-module

Demo scaffold from test run

## Layout

```text
demo-module/
  main.tf              # resources + modules/naming call
  variables.tf         # inputs (incl. tags from caller)
  outputs.tf           # outputs for consumers
  versions.tf          # terraform + azurerm constraints
  README.md
  examples/basic/      # smoke / usage example
  tests/               # placeholder (use examples/basic for local validate)
```

## Conventions

- **Names** - every resource name comes from [modules/naming](../../naming). Do not hardcode names.
- **Tags** - this module accepts `var.tags`. The **caller** (env stack or example) composes the map with [modules/tags](../../tags) and passes `tags = module.tags.tags`.
- **Region** - `location` is always a variable; never bake in a region.

## Naming integration (inside this module)

```hcl
module "demo_module_name" {
  source = "../../naming"

  resource_type   = "demo_module" # TODO: map to a naming resource_type key
  location        = var.location
  environment     = var.environment
  subscription_id = var.subscription_id
  description     = var.description
  unique_id       = var.unique_id
}

# resource "azurerm_TODO" "this" {
#   name = module.demo_module_name.name
#   tags = var.tags
#   ...
# }
```

## Tags integration (caller / env stack)

Resource modules do **not** call `modules/tags` themselves. The caller merges tags and passes them in:

```hcl
module "tags" {
  source = "../../../../tags" # from examples/basic; adjust for env stacks

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
  source = "../.." # from examples/basic; env stacks use modules/<category>/demo-module

  resource_group_name = "rg-example"
  location            = "uksouth"
  environment         = "dev"
  subscription_id     = "vdi"
  description         = "example"
  unique_id           = "01"

  tags = module.tags.tags
}
```

## Azure resources

- TODO(deploy): list `azurerm_*` resources created by this module.

## Outputs

- TODO(deploy): document outputs once defined in `outputs.tf`.

See [examples/basic](examples/basic) for usage.