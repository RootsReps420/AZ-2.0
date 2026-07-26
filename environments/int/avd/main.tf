# environments/int/avd — MSH host pools + per-BU scaling plans (+ decom siblings)
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

  # Legacy params/int/environment.json workspaceFriendlyName
  friendly_name = "DevTest Shared Desktops"

  application_groups = {
    for k, hp in module.hostpool : "dag-${k}" => {
      host_pool_id  = hp.hostpool_id
      type          = "Desktop"
      friendly_name = local.msh_host_pools[k].app_group_friendly_name
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

  host_pool_type           = "Pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = each.value.maximum_sessions_allowed
  validate_environment     = each.value.validate_environment
  description              = each.value.description
  custom_rdp_properties    = each.value.custom_rdp_properties
  start_vm_on_connect      = false
  # Legacy Bicep PT175H10M ≈ 175 hours (time_rotating is hour-granular)
  token_validity_hours     = 175

  scheduled_agent_updates = {
    enabled                   = true
    timezone                  = "GMT Standard Time"
    use_session_host_timezone = false
    schedules = [{
      day_of_week = "Saturday"
      hour_of_day = 1
    }]
  }

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

  time_zone      = "GMT Standard Time"
  exclusion_tag  = "spExclude"
  pooled_schedules = {
    for sk in each.value.schedule_keys : sk => local.msh_schedule_catalog[sk]
  }
  host_pool_associations = {
    (each.key) = {
      hostpool_id          = module.hostpool[each.key].hostpool_id
      scaling_plan_enabled = true
    }
  }

  log_analytics_workspace_id = var.law_id
  tags                       = module.tags.tags
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

  time_zone     = "GMT Standard Time"
  exclusion_tag = "spExclude"
  pooled_schedules = {
    standard_week_schedule = local.msh_decom_schedule
  }
  host_pool_associations = {
    (each.key) = {
      hostpool_id          = module.hostpool[each.key].hostpool_id
      scaling_plan_enabled = false # Standard active by default; toggle via ops when pool in decom
    }
  }

  log_analytics_workspace_id = var.law_id
  tags                       = module.tags.tags
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
