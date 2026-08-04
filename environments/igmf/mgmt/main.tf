# environments/igmf/mgmt — LAW + mgmt spoke (agent VMSS stays PS)
# IGMF sandbox (ignitemyfire.co.uk). CIDRs reuse int ranges (isolated tenant).

locals {
  location = var.location
  env      = var.environment
}

module "tags" {
  source = "../../../modules/tags"

  workload    = "vdi-platform"
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
  description     = "mgmt"
}

resource "azurerm_resource_group" "mgmt" {
  name     = module.rg_name.name
  location = local.location
  tags     = module.tags.tags
}

module "management" {
  source = "../../../modules/platform/management"

  name                = "vdi"
  resource_group_name = azurerm_resource_group.mgmt.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env
  unique_id           = "01"

  law_retention_in_days = 30
  # Legacy int law params: p_resourcePermissions = true
  law_allow_resource_only_permissions = true
  create_data_collection_endpoint     = true
  # Keep thin Insights DCR here; full MSH rule set lives in avd (modules/platform/dcr-msh)
  create_avd_insights_dcr = true

  action_groups = {
    devices_lab = {
      short_name = "acg-devices"
      enabled    = true
      email_receivers = {
        DevicesLabEmailReceiver = {
          email_address = var.alert_action_group_email
        }
      }
    }
  }

  # Skip scheduled-query alert *creation* in IGMF. Azure validates KQL against the
  # LAW schema at create time even when enabled=false; a fresh workspace has no
  # WVD* tables (WVDConnections, WVDAutoscaleEvaluationPooled, WVDAgentHealthStatus)
  # until AVD diagnostics ingest — create then 400s. Metric alerts are fine.
  #
  # To restore after AVD/tables exist: set
  #   scheduled_query_alerts = local.scheduled_query_alerts
  # Definitions stay in alerts.tf (local.scheduled_query_alerts).
  scheduled_query_alerts = {}
  metric_alerts          = local.metric_alerts

  tags = module.tags.tags
}

# Legacy alert_msi_identity.bicep — used by vCPU quota scheduled queries (Wave C alert rules)
resource "azurerm_user_assigned_identity" "alert_logs" {
  count = var.enable_alert_uami ? 1 : 0

  name                = "custom-log-alerts-msi"
  resource_group_name = azurerm_resource_group.mgmt.name
  location            = local.location
  tags                = module.tags.tags
}

# Legacy access.bicep — DevOps SP Virtual Machine Contributor on mgmt subscription
resource "azurerm_role_assignment" "devops_vm_contributor" {
  count = var.devops_vm_contributor_principal_id != null ? 1 : 0

  scope                = "/subscriptions/${var.azure_subscription_id}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = var.devops_vm_contributor_principal_id
}

# Mgmt spoke — Hub01 + legacy default-to-firewall RT. Agent VMSS not TF-managed.
module "spoke_mgmt" {
  source = "../../../modules/core/spoke-pers"

  name                = "mgmt"
  resource_group_name = azurerm_resource_group.mgmt.name
  location            = local.location
  subscription_id     = var.subscription_code
  environment         = local.env
  unique_id           = "01"

  # VERIFIED: net_mgmt_vnetAddressSpace == net_mgmt_subnetAgents == 10.170.139.192/26
  address_space = var.mgmt_address_space
  dns_servers   = var.dns_servers

  subnets = {
    "AgentsSubnet" = {
      address_prefixes  = var.mgmt_address_space
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      # Legacy params-netsec: deny east-west using AgentsSubnet CIDR (not VirtualNetwork tag)
      security_rules = {
        "deny-subnet-inbound-subnet" = {
          priority                     = 4000
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_range            = "*"
          destination_port_range       = "*"
          source_address_prefixes      = var.mgmt_address_space
          destination_address_prefixes = var.mgmt_address_space
        }
      }
    }
  }

  hub01_id                  = var.hub01_id
  hub01_firewall_private_ip = var.hub01_firewall_private_ip
  tags                      = module.tags.tags
}

resource "azurerm_role_assignment" "mgmt" {
  for_each = var.mgmt_role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}
