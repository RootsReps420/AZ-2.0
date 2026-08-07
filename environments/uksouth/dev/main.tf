# ---------------------------------------------------------------------------
# environments/uksouth/dev
#
# Region/environment root. Configuration only — variable values and module
# calls. All logic lives in modules/. This root composes:
#   - Connectivity platform : firewall-policy, hub-secured (Hub01),
#                             hub-unsecured (Hub02), management (LAW)
#   - One PERS lab          : spoke-pers, keyvault, storage-fslogix, hostpool,
#                             workspace, scalingplan
#   - One MSH lab           : spoke-msh, hostpool, workspace
#   - Images                : gallery, image-definition (PERS + MSH base)
#
# The global Virtual WAN lives in environments/vwan; its id is passed in via
# var.virtual_wan_id.
# ---------------------------------------------------------------------------

locals {
  location = var.location
  env      = var.environment
}

# ---------------------------------------------------------------------------
# Tags (per workload)
# ---------------------------------------------------------------------------

module "tags_platform" {
  source = "../../../modules/tags"

  workload    = "vdi-platform"
  environment = local.env
  region      = local.location
  mandatory   = var.mandatory_tags
}

module "tags_pers" {
  source = "../../../modules/tags"

  workload    = "vdi-pers"
  environment = local.env
  region      = local.location
  mandatory   = var.mandatory_tags
}

module "tags_mult" {
  source = "../../../modules/tags"

  workload    = "vdi-mult"
  environment = local.env
  region      = local.location
  mandatory   = var.mandatory_tags
}

# ---------------------------------------------------------------------------
# Resource groups
# ---------------------------------------------------------------------------

module "rg_connectivity_name" {
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code_conn
  environment     = local.env
  description     = "connectivity"
}

module "rg_management_name" {
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code_conn
  environment     = local.env
  description     = "management"
}

module "rg_pers_name" {
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code_vdi
  environment     = local.env
  description     = "pers-lab01"
}

module "rg_mult_name" {
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code_vdi
  environment     = local.env
  description     = "mult-fin"
}

module "rg_images_name" {
  source = "../../../modules/naming"

  resource_type   = "resource_group"
  location        = local.location
  subscription_id = var.subscription_code_vdi
  environment     = local.env
  description     = "images"
}

resource "azurerm_resource_group" "connectivity" {
  name     = module.rg_connectivity_name.name
  location = local.location
  tags     = module.tags_platform.tags
}

resource "azurerm_resource_group" "management" {
  name     = module.rg_management_name.name
  location = local.location
  tags     = module.tags_platform.tags
}

resource "azurerm_resource_group" "pers" {
  name     = module.rg_pers_name.name
  location = local.location
  tags     = module.tags_pers.tags
}

resource "azurerm_resource_group" "mult" {
  name     = module.rg_mult_name.name
  location = local.location
  tags     = module.tags_mult.tags
}

resource "azurerm_resource_group" "images" {
  name     = module.rg_images_name.name
  location = local.location
  tags     = module.tags_platform.tags
}

# ---------------------------------------------------------------------------
# Management / observability (built first — LAW id feeds diagnostics)
# ---------------------------------------------------------------------------

module "management" {
  source = "../../../modules/platform/management"

  name                = "vdi"
  resource_group_name = azurerm_resource_group.management.name
  location            = local.location
  subscription_id     = var.subscription_code_conn
  environment         = local.env
  unique_id           = "01"

  law_retention_in_days           = 30 # TODO(deploy): confirm retention vs data-classification/retention policy (30-730 days)
  create_data_collection_endpoint = true
  create_avd_insights_dcr         = true

  tags = module.tags_platform.tags
}

# ---------------------------------------------------------------------------
# Connectivity platform
# ---------------------------------------------------------------------------

module "firewall_policy" {
  source = "../../../modules/platform/firewall-policy"

  name                = "hub01"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = local.location
  subscription_id     = var.subscription_code_conn
  environment         = local.env
  # unique_id omitted: the name "hub01" already carries the instance number
  # (avoids a redundant ...-fwp-hub01-01 per TDA §9.2 {description|id}).

  # TODO(deploy): no rule_collection_groups / ip_groups are set here, so this
  #               policy is EMPTY. Because Hub01 Routing Intent forces all spoke
  #               traffic through the firewall, an empty policy means egress is
  #               DEFAULT-DENY. Add baseline AVD allow rules (AVD service
  #               tags/FQDNs, KMS activation, Entra/Kerberos, storage) before
  #               session hosts can function. See this env's README.
  sku = "Standard"
  dns = {
    proxy_enabled = true
    servers       = []
  }

  tags = module.tags_platform.tags
}

module "hub_secured" {
  source = "../../../modules/platform/hub-secured"

  name                = "hub01"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = local.location
  subscription_id     = var.subscription_code_conn
  environment         = local.env
  # unique_id omitted: the name "hub01" already carries the instance number.

  virtual_wan_id     = var.virtual_wan_id
  address_prefix     = var.hub01_address_prefix
  firewall_policy_id = module.firewall_policy.policy_id

  express_route = {
    scale_units        = 1
    circuit_peering_id = var.expressroute_circuit_peering_id # TODO(deploy): null = ER gateway only; set the circuit private-peering id to connect ExpressRoute
  }

  log_analytics_workspace_id = module.management.law_id
  tags                       = module.tags_platform.tags
}

module "hub_unsecured" {
  source = "../../../modules/platform/hub-unsecured"

  name                = "hub02"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = local.location
  subscription_id     = var.subscription_code_conn
  environment         = local.env
  # unique_id omitted: the name "hub02" already carries the instance number.

  virtual_wan_id = var.virtual_wan_id
  address_prefix = var.hub02_address_prefix

  vpn = {
    scale_unit         = 1
    routing_preference = "Microsoft Network"
  }

  log_analytics_workspace_id = module.management.law_id
  tags                       = module.tags_platform.tags
}

# ---------------------------------------------------------------------------
# PERS lab
# ---------------------------------------------------------------------------

module "spoke_pers" {
  source = "../../../modules/core/spoke-pers"

  name                = "pers-lab01"
  resource_group_name = azurerm_resource_group.pers.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env
  unique_id           = "01"

  address_space = var.pers_spoke_address_space
  subnets = {
    "snet-sessionhosts" = {
      address_prefixes = [cidrsubnet(var.pers_spoke_address_space[0], 2, 0)]
    }
  }

  hub01_id = module.hub_secured.hub_id

  tags = module.tags_pers.tags
}

module "keyvault_pers" {
  source = "../../../modules/core/keyvault"

  name                = "pers"
  resource_group_name = azurerm_resource_group.pers.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env
  unique_id           = "prslb01" # TODO(deploy): 7-char id (TDA §11.1). Key Vault names are GLOBALLY unique - make this unique per deployment.

  keys = {
    "cmk-fslogix" = {
      key_type = "RSA"
      key_size = 2048
      key_opts = ["unwrapKey", "wrapKey"]
    }
  }

  tags = module.tags_pers.tags
}

module "storage_fslogix_pers" {
  source = "../../../modules/core/storage-fslogix"

  name                = "pers"
  resource_group_name = azurerm_resource_group.pers.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env
  unique_id           = "01"

  # TODO(deploy): AADKERB (Entra ID Kerberos) also needs tenant-level Entra
  #               Kerberos enablement and per-user RBAC ("Storage File Data SMB
  #               Share Contributor") - neither is managed here. See README.
  azure_files_authentication = {
    directory_type = "AADKERB"
  }

  shares = {
    "profiles" = { quota_gb = 1024 }
  }

  tags = module.tags_pers.tags
}

module "hostpool_pers" {
  source = "../../../modules/avd/hostpool"

  name                = "pers"
  resource_group_name = azurerm_resource_group.pers.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env
  unique_id           = "01"

  host_pool_type                   = "Personal"
  load_balancer_type               = "Persistent"
  personal_desktop_assignment_type = "Automatic"

  log_analytics_workspace_id = module.management.law_id
  tags                       = module.tags_pers.tags
}

module "workspace_pers" {
  source = "../../../modules/avd/workspace"

  name                = "pers"
  resource_group_name = azurerm_resource_group.pers.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env
  unique_id           = "01"

  friendly_name = "Personal VDI"
  application_groups = {
    "desktop" = {
      host_pool_id                 = module.hostpool_pers.hostpool_id
      type                         = "Desktop"
      friendly_name                = "Personal Desktop"
      default_desktop_display_name = "Desktop"
    }
  }

  tags = module.tags_pers.tags
}

module "scalingplan_pers" {
  source = "../../../modules/avd/scalingplan"

  name                = "pers"
  resource_group_name = azurerm_resource_group.pers.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env
  unique_id           = "01"

  friendly_name = "PERS UK South"
  host_pool_associations = {
    "pers" = {
      hostpool_id          = module.hostpool_pers.hostpool_id
      scaling_plan_enabled = true
    }
  }

  personal_schedules = {
    "weekdays" = {
      properties = {
        daysOfWeek                        = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        rampUpStartTime                   = { hour = 7, minute = 0 }
        rampUpAutoStartHosts              = "WithAssignedUser"
        rampUpStartVMOnConnect            = "Enable"
        rampUpActionOnDisconnect          = "None"
        rampUpMinutesToWaitOnDisconnect   = 0
        rampUpActionOnLogoff              = "None"
        rampUpMinutesToWaitOnLogoff       = 0
        peakStartTime                     = { hour = 9, minute = 0 }
        peakStartVMOnConnect              = "Enable"
        peakActionOnDisconnect            = "None"
        peakMinutesToWaitOnDisconnect     = 0
        peakActionOnLogoff                = "None"
        peakMinutesToWaitOnLogoff         = 0
        rampDownStartTime                 = { hour = 18, minute = 0 }
        rampDownStartVMOnConnect          = "Enable"
        rampDownActionOnDisconnect        = "None"
        rampDownMinutesToWaitOnDisconnect = 0
        rampDownActionOnLogoff            = "Deallocate"
        rampDownMinutesToWaitOnLogoff     = 30
        offPeakStartTime                  = { hour = 20, minute = 0 }
        offPeakStartVMOnConnect           = "Enable"
        offPeakActionOnDisconnect         = "None"
        offPeakMinutesToWaitOnDisconnect  = 0
        offPeakActionOnLogoff             = "Deallocate"
        offPeakMinutesToWaitOnLogoff      = 30
      }
    }
  }

  tags = module.tags_pers.tags
}

# ---------------------------------------------------------------------------
# MSH lab
# ---------------------------------------------------------------------------

module "spoke_msh" {
  source = "../../../modules/core/spoke-msh"

  name                = "mult-fin"
  resource_group_name = azurerm_resource_group.mult.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env
  unique_id           = "01"

  address_space = var.msh_spoke_address_space
  subnets = {
    "snet-sessionhosts" = {
      address_prefixes = [cidrsubnet(var.msh_spoke_address_space[0], 2, 0)]
    }
  }

  hub01_id                  = module.hub_secured.hub_id
  hub02_id                  = module.hub_unsecured.hub_id
  hub01_firewall_private_ip = module.hub_secured.firewall_private_ip

  tags = module.tags_mult.tags
}

module "hostpool_mult" {
  source = "../../../modules/avd/hostpool"

  name                = "mult-fin"
  resource_group_name = azurerm_resource_group.mult.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env
  unique_id           = "01"

  host_pool_type           = "Pooled"
  load_balancer_type       = "DepthFirst"
  maximum_sessions_allowed = 18

  log_analytics_workspace_id = module.management.law_id
  tags                       = module.tags_mult.tags
}

module "workspace_mult" {
  source = "../../../modules/avd/workspace"

  name                = "mult-fin"
  resource_group_name = azurerm_resource_group.mult.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env
  unique_id           = "01"

  friendly_name = "Finance Multi-Session"
  application_groups = {
    "desktop" = {
      host_pool_id                 = module.hostpool_mult.hostpool_id
      type                         = "Desktop"
      friendly_name                = "Finance Desktop"
      default_desktop_display_name = "Finance"
    }
  }

  tags = module.tags_mult.tags
}

# ---------------------------------------------------------------------------
# Images
# ---------------------------------------------------------------------------

module "gallery" {
  source = "../../../modules/gallery/gallery"

  name                = "avd"
  resource_group_name = azurerm_resource_group.images.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env
  unique_id           = "01"

  description = "AVD image gallery (PERS and MSH definitions)"

  tags = module.tags_platform.tags
}

module "image_pers" {
  source = "../../../modules/gallery/image-definition"

  name                = "pers-win11"
  gallery_name        = module.gallery.gallery_name
  resource_group_name = azurerm_resource_group.images.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env

  os_type       = "Windows"
  security_type = "TrustedLaunch"
  identifier = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-avd-pers"
  }

  tags = module.tags_pers.tags
}

module "image_msh_base" {
  source = "../../../modules/gallery/image-definition"

  name                = "msh-win11-base"
  gallery_name        = module.gallery.gallery_name
  resource_group_name = azurerm_resource_group.images.name
  location            = local.location
  subscription_id     = var.subscription_code_vdi
  environment         = local.env

  os_type       = "Windows"
  security_type = "TrustedLaunch"
  identifier = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-avd-msh-base"
  }

  tags = module.tags_mult.tags
}
