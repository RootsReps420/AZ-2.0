# ---------------------------------------------------------------------------
# Platform — Management / Observability
#
# Deploys the shared observability platform for a region/environment:
#   - Log Analytics Workspace (all platform resources send diagnostics here)
#   - Data Collection Endpoint (optional)
#   - AVD Insights Data Collection Rule (optional) -> performance counters and
#     Windows event logs collected from session hosts into LAW
#   - Action Groups (map-driven)
#   - Metric alerts, Activity Log alerts, Scheduled Query alerts (map-driven)
#   - Workbooks (map-driven)
#
# All resource names come from modules/naming. Alerts reference action groups by
# their key in var.action_groups — callers never handle generated IDs.
# ---------------------------------------------------------------------------

module "law_name" {
  source = "../../naming"

  resource_type   = "log_analytics_workspace"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = var.name
  unique_id       = var.unique_id
}

module "dce_name" {
  source = "../../naming"

  resource_type   = "data_collection_endpoint"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = var.name
  unique_id       = var.unique_id
}

module "dcr_name" {
  source = "../../naming"

  resource_type   = "data_collection_rule"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = "avd-insights"
  unique_id       = var.unique_id
}

module "action_group_names" {
  source   = "../../naming"
  for_each = var.action_groups

  resource_type   = "action_group"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = each.key
}

module "metric_alert_names" {
  source   = "../../naming"
  for_each = var.metric_alerts

  resource_type   = "metric_alert"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = each.key
}

module "activity_alert_names" {
  source   = "../../naming"
  for_each = var.activity_log_alerts

  resource_type   = "activity_log_alert"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = each.key
}

module "query_alert_names" {
  source   = "../../naming"
  for_each = var.scheduled_query_alerts

  resource_type   = "scheduled_query_alert"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = each.key
}

# ---------------------------------------------------------------------------
# Log Analytics Workspace
# ---------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "this" {
  name                = module.law_name.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.law_sku
  retention_in_days   = var.law_retention_in_days
  daily_quota_gb      = var.law_daily_quota_gb
  # Legacy p_resourcePermissions / enableLogAccessUsingOnlyResourcePermissions
  allow_resource_only_permissions = var.law_allow_resource_only_permissions
  tags                            = var.tags
}

# ---------------------------------------------------------------------------
# Data Collection Endpoint + AVD Insights Data Collection Rule
# ---------------------------------------------------------------------------

resource "azurerm_monitor_data_collection_endpoint" "this" {
  count = var.create_data_collection_endpoint ? 1 : 0

  name                = module.dce_name.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_monitor_data_collection_rule" "avd" {
  count = var.create_avd_insights_dcr ? 1 : 0

  name                        = module.dcr_name.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  data_collection_endpoint_id = var.create_data_collection_endpoint ? azurerm_monitor_data_collection_endpoint.this[0].id : null
  tags                        = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
      name                  = "law-dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf", "Microsoft-Event"]
    destinations = ["law-dest"]
  }

  data_sources {
    performance_counter {
      name                          = "avd-perf"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = var.avd_dcr_sampling_seconds
      counter_specifiers            = var.avd_dcr_counters
    }

    windows_event_log {
      name           = "avd-events"
      streams        = ["Microsoft-Event"]
      x_path_queries = var.avd_dcr_event_xpaths
    }
  }
}

# ---------------------------------------------------------------------------
# Action Groups
# ---------------------------------------------------------------------------

resource "azurerm_monitor_action_group" "this" {
  for_each = var.action_groups

  name                = module.action_group_names[each.key].name
  resource_group_name = var.resource_group_name
  short_name          = each.value.short_name
  enabled             = each.value.enabled
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = each.value.email_receivers
    content {
      name                    = email_receiver.key
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }

  dynamic "webhook_receiver" {
    for_each = each.value.webhook_receivers
    content {
      name                    = webhook_receiver.key
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = true
    }
  }
}

# ---------------------------------------------------------------------------
# Metric Alerts
# ---------------------------------------------------------------------------

resource "azurerm_monitor_metric_alert" "this" {
  for_each = var.metric_alerts

  name                     = coalesce(each.value.display_name, module.metric_alert_names[each.key].name)
  resource_group_name      = var.resource_group_name
  scopes                   = each.value.scopes
  description              = each.value.description
  severity                 = each.value.severity
  frequency                = each.value.frequency
  window_size              = each.value.window_size
  enabled                  = each.value.enabled
  auto_mitigate            = each.value.auto_mitigate
  target_resource_type     = each.value.target_resource_type
  target_resource_location = each.value.target_resource_location
  tags                     = var.tags

  criteria {
    metric_namespace = each.value.criteria.metric_namespace
    metric_name      = each.value.criteria.metric_name
    aggregation      = each.value.criteria.aggregation
    operator         = each.value.criteria.operator
    threshold        = each.value.criteria.threshold

    dynamic "dimension" {
      for_each = each.value.criteria.dimensions
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }
  }

  dynamic "action" {
    for_each = each.value.action_group_keys
    content {
      action_group_id = azurerm_monitor_action_group.this[action.value].id
    }
  }
}

# ---------------------------------------------------------------------------
# Activity Log Alerts
# ---------------------------------------------------------------------------

resource "azurerm_monitor_activity_log_alert" "this" {
  for_each = var.activity_log_alerts

  name                = module.activity_alert_names[each.key].name
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = each.value.scopes
  description         = each.value.description
  tags                = var.tags

  criteria {
    category       = each.value.criteria.category
    operation_name = each.value.criteria.operation_name
    level          = each.value.criteria.level
    resource_type  = each.value.criteria.resource_type
  }

  dynamic "action" {
    for_each = each.value.action_group_keys
    content {
      action_group_id = azurerm_monitor_action_group.this[action.value].id
    }
  }
}

# ---------------------------------------------------------------------------
# Scheduled Query Alerts (v2)
# ---------------------------------------------------------------------------

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "this" {
  for_each = var.scheduled_query_alerts

  name                              = coalesce(each.value.display_name, module.query_alert_names[each.key].name)
  resource_group_name               = var.resource_group_name
  location                          = var.location
  scopes                            = coalesce(each.value.scopes, [azurerm_log_analytics_workspace.this.id])
  severity                          = each.value.severity
  evaluation_frequency              = each.value.evaluation_frequency
  window_duration                   = each.value.window_duration
  description                       = each.value.description
  enabled                           = each.value.enabled
  auto_mitigation_enabled           = each.value.auto_mitigation_enabled
  mute_actions_after_alert_duration = each.value.mute_actions_after_alert_duration
  tags                              = var.tags

  dynamic "identity" {
    for_each = length(each.value.identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = each.value.identity_ids
    }
  }

  criteria {
    query                   = each.value.query
    time_aggregation_method = each.value.time_aggregation_method
    threshold               = each.value.threshold
    operator                = each.value.operator
    metric_measure_column   = each.value.metric_measure_column
    resource_id_column      = each.value.resource_id_column

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  dynamic "action" {
    for_each = length(each.value.action_group_keys) > 0 ? [1] : []
    content {
      action_groups = [for k in each.value.action_group_keys : azurerm_monitor_action_group.this[k].id]
    }
  }
}

# ---------------------------------------------------------------------------
# Workbooks
# ---------------------------------------------------------------------------

resource "azurerm_application_insights_workbook" "this" {
  for_each = var.workbooks

  name                = uuidv5("url", each.key)
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = each.value.display_name
  data_json           = each.value.data_json
  tags                = var.tags
}
