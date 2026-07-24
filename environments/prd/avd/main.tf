# environments/prd/avd — MSH host pools + per-BU scaling plans (+ decom siblings)
# Session hosts stay PowerShell. Registration token outputs for Get-PlacementAVD.

locals {
  location = var.location
  env      = var.environment
}

module "tags" {
  source = "../../../modules/tags"

  workload    = "vdi-mult"
  environment = local.env
  region      = local.location
  mandatory   = var.mandatory_tags
}

module "rg_name" {
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code
  environment     = local.env
  description     = "avd-mult"
}

resource "azurerm_resource_group" "avd" {
  name     = module.rg_name.name
  location = local.location
  tags     = module.tags.tags
}

module "keyvault" {
  source = "../../../modules/core/keyvault"

  name                = "avd"
  resource_group_name = azurerm_resource_group.avd.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env
  unique_id           = var.keyvault_unique_id

  tags = module.tags.tags
}

module "workspace" {
  source = "../../../modules/avd/workspace"

  name                = "mult"
  resource_group_name = azurerm_resource_group.avd.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env
  unique_id           = "01"

  application_groups = {
    for k, hp in module.hostpool : "dag-${k}" => {
      host_pool_id = hp.hostpool_id
      type         = "Desktop"
    }
  }

  tags = module.tags.tags
}

module "hostpool" {
  source   = "../../../modules/avd/hostpool"
  for_each = local.msh_host_pools

  name                = "mult-${each.key}"
  resource_group_name = azurerm_resource_group.avd.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env
  # unique_id omitted — description already includes bu-pool

  host_pool_type     = "Pooled"
  load_balancer_type = "BreadthFirst"
  maximum_sessions_allowed = var.default_max_session_limit

  log_analytics_workspace_id = var.law_id
  tags                       = module.tags.tags
}

# One scaling plan per host pool — schedules from shared catalog (BU 005 + canary variants)
module "scaling_plan" {
  source   = "../../../modules/avd/scalingplan"
  for_each = local.msh_host_pools

  name                = "mult-${each.key}"
  resource_group_name = azurerm_resource_group.avd.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  time_zone = "GMT Standard Time"
  pooled_schedules = {
    for sk in each.value.schedule_keys : sk => local.msh_schedule_catalog[sk]
  }
  host_pool_associations = {
    (each.key) = {
      hostpool_id          = module.hostpool[each.key].hostpool_id
      scaling_plan_enabled = true
    }
  }

  tags = module.tags.tags
}

# Decom sibling plans — catalog from scalingPlanSchedulesDecom.json
module "scaling_plan_decom" {
  source   = "../../../modules/avd/scalingplan"
  for_each = local.msh_host_pools

  name                = "mult-${each.key}-decom"
  resource_group_name = azurerm_resource_group.avd.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  time_zone = "GMT Standard Time"
  pooled_schedules = {
    standard_week_schedule = local.msh_decom_schedule
  }
  host_pool_associations = {
    (each.key) = {
      hostpool_id          = module.hostpool[each.key].hostpool_id
      scaling_plan_enabled = false # Standard active by default; toggle via ops when pool in decom
    }
  }

  tags = module.tags.tags
}

# ---------------------------------------------------------------------------
# Compute gallery + image definitions (Packer builds versions)
# ---------------------------------------------------------------------------

module "rg_gallery_name" {
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code
  environment     = local.env
  description     = "gallery-images"
}

resource "azurerm_resource_group" "gallery" {
  name     = module.rg_gallery_name.name
  location = local.location
  tags     = module.tags.tags
}

module "gallery" {
  source = "../../../modules/gallery/gallery"

  name                = "avd"
  resource_group_name = azurerm_resource_group.gallery.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env
  unique_id           = "01"

  # TODO(deploy): Packer MSI principal_ids from tfvars
  role_assignments = var.gallery_role_assignments

  tags = module.tags.tags
}

module "image_definition" {
  source   = "../../../modules/gallery/image-definition"
  for_each = local.image_definitions

  name                = each.key
  gallery_name        = module.gallery.gallery_name
  resource_group_name = azurerm_resource_group.gallery.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  os_type            = each.value.os_type
  hyper_v_generation = each.value.hyper_v_generation
  security_type      = each.value.security_type
  identifier         = each.value.identifier

  tags = module.tags.tags
}
