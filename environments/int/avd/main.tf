# environments/int/avd — MSH host pools + per-BU scaling plans (+ decom siblings)
# Session hosts stay PowerShell. Registration token outputs for Get-PlacementAVD.

locals {
  location = var.location
  env      = var.environment
}

module "tags_mult" {
  source = "../../../modules/tags"

  workload    = "mult"
  environment = local.env
  region      = local.location
  mandatory   = var.mandatory_tags
}

module "tags_pers" {
  source = "../../../modules/tags"

  workload    = "pers"
  environment = local.env
  region      = local.location
  mandatory   = var.mandatory_tags
}

module "tags_priv" {
  source = "../../../modules/tags"

  workload    = "priv"
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
  tags     = module.tags_mult.tags
}

module "keyvault" {
  source = "../../../modules/core/keyvault"

  name                = "avd"
  resource_group_name = azurerm_resource_group.avd.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env
  unique_id           = var.keyvault_unique_id

  tags = module.tags_mult.tags
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

  tags = module.tags_mult.tags
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
  token_validity_hours = 175

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
  tags                       = module.tags_mult.tags
}

# One scaling plan per host pool — schedules from shared catalog (BU 005 + canary variants).
#
# TODO(poolSPType): Legacy does NOT manually swap plans. Rotation/decom pipelines
# (vdi_mult_sessionhost_*) set host-pool status/spType; VDI_Environment_Helpers.psm1
# injects poolSPType (RotationGrace → Decom, else Standard); Mult_DeployAVD /
# vdi_mult_avd_release then puts the HP in exactly ONE plan's hostPoolReferences
# (inactive sibling = empty array). Azure allows only one association per pool.
# Today TF always associates Standard and leaves decom empty — fine for steady
# state / first cutover, but will fight live rotation on re-apply. Before cutover
# with active rotation: discover live poolSPType (ARG/status) and drive which
# module gets the association (never both; never enabled=false dual-link).
module "scaling_plan" {
  source   = "../../../modules/avd/scalingplan"
  for_each = local.msh_host_pools

  name                = "mult-${each.key}"
  resource_group_name = azurerm_resource_group.avd.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env

  time_zone     = "GMT Standard Time"
  exclusion_tag = "spExclude"
  pooled_schedules = {
    for sk in each.value.schedule_keys : sk => local.msh_schedule_catalog[sk]
  }
  # Steady-state assumption: Standard. See TODO(poolSPType) above.
  host_pool_associations = {
    (each.key) = {
      hostpool_id          = module.hostpool[each.key].hostpool_id
      scaling_plan_enabled = true
    }
  }

  log_analytics_workspace_id = var.law_id
  tags                       = module.tags_mult.tags
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
  # Unattached until poolSPType=Decom (see TODO on module.scaling_plan). Plan object
  # must exist so rotation can point the HP here without recreating schedules.
  host_pool_associations = {}

  log_analytics_workspace_id = var.law_id
  tags                       = module.tags_mult.tags
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
  tags     = module.tags_mult.tags
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

  tags = module.tags_mult.tags
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

  tags = module.tags_mult.tags
}

# Multisession data collection (legacy vdi_dcr.bicep) — associations stay with VMs
module "dcr_msh" {
  count  = var.law_id != null ? 1 : 0
  source = "../../../modules/platform/dcr-msh"

  resource_group_name        = azurerm_resource_group.avd.name
  location                   = local.location
  log_analytics_workspace_id = var.law_id
  dce_name                   = "uks-${local.env}-vdi-avd-dce-mult-all"
  dcr_main_name              = "uks-${local.env}-vdi-avd-dcr-mult"
  dcr_insights_name          = "uks-${local.env}-vdi-avd-dcr-mult-vminsights"
  dcr_fsl_name               = "uks-${local.env}-vdi-avd-dcr-multfslp"
  dcr_wss_name               = "uks-${local.env}-vdi-avd-dcr-multwss"
  tags                       = module.tags_mult.tags
}

# Legacy Desktop Virtualization Power On Off Contributor — AVD broker + mult lab subs
locals {
  wvd_power_on_off_scopes = var.wvd_power_on_off_principal_id == null ? {} : merge(
    { avd = var.azure_subscription_id },
    var.wvd_power_on_off_lab_subscription_ids,
  )
}

resource "azurerm_role_assignment" "wvd_power_on_off" {
  for_each = local.wvd_power_on_off_scopes

  scope                = "/subscriptions/${each.value}"
  role_definition_name = "Desktop Virtualization Power On Off Contributor"
  principal_id         = var.wvd_power_on_off_principal_id
}
