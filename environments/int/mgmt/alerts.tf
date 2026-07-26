# Active platform alerts — legacy platform/bicep/alerts (15 template types).
# Rules are deployed for int+prd; enabled only when environment contains "prd".
# Filshare metric alerts need storage file-service scopes from labs (optional map).
# Activity log alerts (resource/service health) live here (complex criteria).
# Scheduled query + metric alerts are passed into module.management.

locals {
  alerts_enabled = local.env == "prd"

  # Multisession host pools excluding administration (999) — legacy v_hostPoolConfigs filter
  alert_msh_pools = [
    "001-00", "001-01", "001-02",
    "002-00", "002-01", "002-02",
    "003-00", "003-01", "003-02",
    "004-00", "004-01", "004-02",
    "005-00", "005-01", "005-02",
    "006-00", "006-01", "006-02",
    "007-00", "007-01", "007-02",
    "008-00", "008-01", "008-02",
    "009-00", "009-01", "009-02",
  ]

  alert_uami_ids = var.enable_alert_uami ? [azurerm_user_assigned_identity.alert_logs[0].id] : []

  # Host-pool alerts scope the subscription hosting LAW/alerts (legacy AVD broker sub)
  alert_hp_scopes = ["/subscriptions/${var.azure_subscription_id}"]

  alert_hp_capacity = {
    for pool in local.alert_msh_pools :
    "hp-capacity-${pool}" => {
      display_name            = "avd-log-alert-hostpool-max-capacity-mult-${pool}"
      severity                = 2
      evaluation_frequency    = "PT15M"
      window_duration         = "PT15M"
      time_aggregation_method = "Count"
      threshold               = 5
      operator                = "GreaterThanOrEqual"
      enabled                 = local.alerts_enabled
      auto_mitigation_enabled = true
      scopes                  = local.alert_hp_scopes
      action_group_keys       = ["devices_lab"]
      description             = "Host pool session occupancy >= 95% for mult-${pool}"
      query                   = <<-KQL
        WVDAutoscaleEvaluationPooled
        | where ScalingPlanResourceId has "mult-${pool}"
        | where SessionOccupancyPercent >= 95
        | project TimeGenerated, ScalingPlanResourceId, SessionCount, HostPoolPercentLoad = SessionOccupancyPercent, UnhealthySessionHostCount, TotalSessionHostCount, ActiveSessionHostsPercent
      KQL
    }
  }

  alert_hp_unhealthy = {
    for pool in local.alert_msh_pools :
    "hp-unhealthy-${pool}" => {
      display_name            = "avd-log-alert-hostpool-unhealthy-mult-${pool}"
      severity                = 1
      evaluation_frequency    = "PT15M"
      window_duration         = "PT15M"
      time_aggregation_method = "Count"
      threshold               = 2
      operator                = "GreaterThanOrEqual"
      enabled                 = local.alerts_enabled
      auto_mitigation_enabled = true
      scopes                  = local.alert_hp_scopes
      action_group_keys       = ["devices_lab"]
      description             = "Unhealthy session hosts on mult-${pool}"
      query                   = <<-KQL
        WVDAutoscaleEvaluationPooled
        | where ScalingPlanResourceId has "mult-${pool}"
        | where UnhealthySessionHostCount >= 1
        | project ScalingPlanResourceId, UnhealthySessionHostCount, SessionCount, TotalSessionHostCount, ActiveSessionHostsPercent
      KQL
    }
  }

  alert_hp_no_resources = {
    for pool in local.alert_msh_pools :
    "hp-nores-${pool}" => {
      display_name            = "avd-log-alert-hostpool-no-resources-mult-${pool}"
      severity                = 1
      evaluation_frequency    = "PT15M"
      window_duration         = "PT15M"
      time_aggregation_method = "Count"
      threshold               = 40
      operator                = "GreaterThanOrEqual"
      enabled                 = local.alerts_enabled
      auto_mitigation_enabled = true
      scopes                  = local.alert_hp_scopes
      action_group_keys       = ["devices_lab"]
      description             = "ConnectionFailedNoHealthyRdshAvailable on mult-${pool}"
      query                   = <<-KQL
        WVDConnections
        | where _ResourceId has "mult-${pool}"
        | project-away TenantId, SourceSystem
        | summarize arg_max(TimeGenerated, *), StartTime = min(iff(State == "Started", TimeGenerated, datetime(null))), ConnectTime = min(iff(State == "Connected", TimeGenerated, datetime(null))) by CorrelationId
        | join kind=leftouter (WVDErrors | summarize Errors = makelist(pack("Code", Code, "CodeSymbolic", CodeSymbolic, "Time", TimeGenerated, "Message", Message, "ServiceError", ServiceError, "Source", Source)) by CorrelationId) on CorrelationId
        | where Errors[0].CodeSymbolic == "ConnectionFailedNoHealthyRdshAvailable"
      KQL
    }
  }

  alert_hp_healthcheck = {
    for pool in local.alert_msh_pools :
    "hp-health-${pool}" => {
      display_name            = "avd-log-alert-hostpool-session-host-health-mult-${pool}"
      severity                = 1
      evaluation_frequency    = "PT15M"
      window_duration         = "PT15M"
      time_aggregation_method = "Count"
      threshold               = 5
      operator                = "GreaterThanOrEqual"
      enabled                 = local.alerts_enabled
      auto_mitigation_enabled = true
      scopes                  = local.alert_hp_scopes
      action_group_keys       = ["devices_lab"]
      description             = "Session host health check failures on mult-${pool}"
      query                   = <<-KQL
        let MapToDesc = (idx: long) { case(idx == 0, "DomainJoin", idx == 1, "DomainTrust", idx == 2, "FSLogix", idx == 3, "SxSStack", idx == 4, "URLCheck", idx == 5, "GenevaAgent", idx == 6, "DomainReachable", idx == 7, "WebRTCRedirector", idx == 8, "SxSStackEncryption", idx == 9, "IMDSReachable", idx == 10, "MSIXPackageStaging", "InvalidIndex") };
        WVDAgentHealthStatus
        | where Status != "Available"
        | where AllowNewSessions == true
        | extend CheckFailed = parse_json(SessionHostHealthCheckResult)
        | mv-expand CheckFailed
        | where CheckFailed.AdditionalFailureDetails.ErrorCode != 0
        | extend HealthCheckName = tolong(CheckFailed.HealthCheckName)
        | extend HealthCheckDesc = MapToDesc(HealthCheckName)
        | where HealthCheckDesc != "InvalidIndex"
        | where _ResourceId has "mult-${pool}"
        | distinct TimeGenerated, SessionHostName, HealthCheckDesc, _ResourceId
      KQL
    }
  }

  alert_hp_user_conn = {
    for pool in local.alert_msh_pools :
    "hp-uconn-${pool}" => {
      display_name            = "avd-log-alert-hostpool-user-connection-mult-${pool}"
      severity                = 2
      evaluation_frequency    = "PT15M"
      window_duration         = "PT15M"
      time_aggregation_method = "Count"
      threshold               = 20
      operator                = "GreaterThanOrEqual"
      enabled                 = local.alerts_enabled
      auto_mitigation_enabled = true
      scopes                  = local.alert_hp_scopes
      action_group_keys       = ["devices_lab"]
      description             = "User connection errors on mult-${pool}"
      query                   = <<-KQL
        WVDConnections
        | project-away TenantId, SourceSystem
        | summarize arg_max(TimeGenerated, *), StartTime = min(iff(State == "Started", TimeGenerated, datetime(null))), ConnectTime = min(iff(State == "Connected", TimeGenerated, datetime(null))) by CorrelationId
        | join kind=leftouter (WVDErrors | summarize Errors = makelist(pack("Code", Code, "CodeSymbolic", CodeSymbolic, "Time", TimeGenerated, "Message", Message, "ServiceError", ServiceError, "Source", Source)) by CorrelationId) on CorrelationId
        | where _ResourceId has "mult-${pool}"
        | extend ErrorShort = tostring(Errors[0].CodeSymbolic)
        | where ErrorShort != ""
        | distinct UserName, ErrorShort, ErrorMessage = tostring(Errors[0].Message), _ResourceId
      KQL
    }
  }

  alert_sub_highcpu = {
    for k, sub_id in var.alert_mult_subscription_ids :
    "sub-highcpu-${k}" => {
      display_name            = "avd-log-alert-VM-highcpu-${k}"
      severity                = 2
      evaluation_frequency    = "PT15M"
      window_duration         = "PT30M"
      time_aggregation_method = "Count"
      threshold               = 2
      operator                = "GreaterThanOrEqual"
      enabled                 = local.alerts_enabled
      auto_mitigation_enabled = true
      action_group_keys       = ["devices_lab"]
      scopes                  = ["/subscriptions/${sub_id}"]
      description             = "VM CPU > 95% on ${k}"
      query                   = <<-KQL
        InsightsMetrics
        | where Origin == "vm.azm.ms"
        | where Namespace == "Processor" and Name == "UtilizationPercentage"
        | summarize CPUPercentageAverage = avg(Val) by bin(TimeGenerated, 30m), Computer, _ResourceId
        | where CPUPercentageAverage > 95
      KQL
    }
  }

  alert_sub_memory = {
    for k, sub_id in var.alert_mult_subscription_ids :
    "sub-mem-${k}" => {
      display_name            = "avd-log-alert-VM-availmemory-${k}"
      severity                = 2
      evaluation_frequency    = "PT15M"
      window_duration         = "PT30M"
      time_aggregation_method = "Count"
      threshold               = 2
      operator                = "GreaterThanOrEqual"
      enabled                 = local.alerts_enabled
      auto_mitigation_enabled = true
      action_group_keys       = ["devices_lab"]
      scopes                  = ["/subscriptions/${sub_id}"]
      description             = "VM available memory < 5% on ${k}"
      query                   = <<-KQL
        InsightsMetrics
        | where Origin == "vm.azm.ms"
        | where Namespace == "Memory" and Name == "AvailableMB"
        | extend TotalMemory = toreal(todynamic(Tags)["vm.azm.ms/memorySizeMB"])
        | extend AvailableMemoryPercentage = (toreal(Val) / TotalMemory) * 100.0
        | summarize AvailableMemoryInPercentageAverage = avg(AvailableMemoryPercentage) by bin(TimeGenerated, 30m), Computer, _ResourceId
        | where AvailableMemoryInPercentageAverage < 5
      KQL
    }
  }

  alert_sub_disk = {
    for k, sub_id in var.alert_mult_subscription_ids :
    "sub-disk-${k}" => {
      display_name            = "avd-log-alert-VM-lowdiskspace-${k}"
      severity                = 2
      evaluation_frequency    = "PT15M"
      window_duration         = "PT1H"
      time_aggregation_method = "Count"
      threshold               = 1
      operator                = "GreaterThanOrEqual"
      enabled                 = local.alerts_enabled
      auto_mitigation_enabled = true
      action_group_keys       = ["devices_lab"]
      scopes                  = ["/subscriptions/${sub_id}"]
      description             = "VM free disk <= 5% on ${k}"
      query                   = <<-KQL
        Perf
        | where (CounterName =~ "% Free Space" and InstanceName =~ "C:") or (CounterName =~ "% Free Space" and InstanceName =~ "D:")
        | extend PercentageFreeSpace = toint(CounterValue)
        | where PercentageFreeSpace <= 5
        | distinct Computer, PercentageFreeSpace, Disk = InstanceName, _ResourceId
      KQL
    }
  }

  alert_sub_startfail = {
    for k, sub_id in merge(var.alert_mult_subscription_ids, var.alert_pers_subscription_ids) :
    "sub-startfail-${k}" => {
      display_name            = "avd-log-alert-VM-vmstartfailure-${k}"
      severity                = 3
      evaluation_frequency    = "PT30M"
      window_duration         = "PT6H"
      time_aggregation_method = "Count"
      threshold               = 1
      operator                = "GreaterThanOrEqual"
      enabled                 = local.alerts_enabled
      auto_mitigation_enabled = true
      action_group_keys       = ["devices_lab"]
      scopes                  = ["/subscriptions/${sub_id}"]
      description             = "VM start failures > 16 per VM on ${k}"
      query                   = <<-KQL
        AzureActivity
        | where OperationNameValue == "MICROSOFT.COMPUTE/VIRTUALMACHINES/START/ACTION" and ActivityStatusValue =~ "Failure"
        | parse _ResourceId with * "virtualmachines/" vmresource:string
        | summarize NoPerVm = count() by vmresource, _ResourceId
        | where NoPerVm > 16
        | project vmresource, Failures = NoPerVm, _ResourceId
      KQL
    }
  }

  alert_sub_vcpu_mult = {
    for k, sub_id in var.alert_mult_subscription_ids :
    "sub-vcpu-mult-${k}" => {
      display_name                      = "avd-log-alert-multi-sub-vcpu-quota-${k}"
      severity                          = 2
      evaluation_frequency              = "P1D"
      window_duration                   = "P1D"
      time_aggregation_method           = "Maximum"
      threshold                         = 80
      operator                          = "GreaterThan"
      enabled                           = local.alerts_enabled
      auto_mitigation_enabled           = false
      mute_actions_after_alert_duration = "PT24H"
      action_group_keys                 = ["devices_lab"]
      scopes                            = ["/subscriptions/${sub_id}"]
      identity_ids                      = local.alert_uami_ids
      metric_measure_column             = "usagePercent"
      resource_id_column                = "id"
      description                       = "Multi lab vCPU quota > 80% on ${k}"
      query                             = <<-KQL
        arg("").QuotaResources
        | where subscriptionId =~ "${sub_id}"
        | where type =~ "microsoft.compute/locations/usages"
        | where isnotempty(properties)
        | mv-expand propertyJson = properties.value limit 400
        | extend usage = propertyJson.currentValue, quota = toint(propertyJson.["limit"]), quotaName = tostring(propertyJson.["name"].value)
        | extend usagePercent = usage * 100 / quota
        | extend id = strcat("/subscriptions/", subscriptionId)
        | where location in~ ("uksouth")
        | where quotaName contains "Family" or quotaName =~ "cores"
        | project id, usagePercent, quotaName, location
      KQL
    }
  }

  alert_sub_vcpu_pers = {
    for k, sub_id in var.alert_pers_subscription_ids :
    "sub-vcpu-pers-${k}" => {
      display_name                      = "avd-log-alert-pers-sub-vcpu-quota-${k}"
      severity                          = 2
      evaluation_frequency              = "P1D"
      window_duration                   = "P1D"
      time_aggregation_method           = "Maximum"
      threshold                         = 90
      operator                          = "GreaterThan"
      enabled                           = local.alerts_enabled
      auto_mitigation_enabled           = false
      mute_actions_after_alert_duration = "PT24H"
      action_group_keys                 = ["devices_lab"]
      scopes                            = ["/subscriptions/${sub_id}"]
      identity_ids                      = local.alert_uami_ids
      metric_measure_column             = "usagePercent"
      resource_id_column                = "id"
      description                       = "Personal lab vCPU quota > 90% on ${k}"
      query                             = <<-KQL
        arg("").QuotaResources
        | where subscriptionId =~ "${sub_id}"
        | where type =~ "microsoft.compute/locations/usages"
        | where isnotempty(properties)
        | mv-expand propertyJson = properties.value limit 400
        | extend usage = propertyJson.currentValue, quota = toint(propertyJson.["limit"]), quotaName = tostring(propertyJson.["name"].value)
        | extend usagePercent = usage * 100 / quota
        | extend id = strcat("/subscriptions/", subscriptionId)
        | where location in~ ("uksouth")
        | where quotaName contains "Family" or quotaName =~ "cores"
        | project id, usagePercent, quotaName, location
      KQL
    }
  }

  scheduled_query_alerts = merge(
    local.alert_hp_capacity,
    local.alert_hp_unhealthy,
    local.alert_hp_no_resources,
    local.alert_hp_healthcheck,
    local.alert_hp_user_conn,
    local.alert_sub_highcpu,
    local.alert_sub_memory,
    local.alert_sub_disk,
    local.alert_sub_startfail,
    local.alert_sub_vcpu_mult,
    local.alert_sub_vcpu_pers,
  )

  # FSLogix fileshare headroom — P2 (15%) + P1 (5%); exclude admin pools via input map
  metric_alerts = merge(
    {
      for k, share in var.alert_fslogix_file_shares :
      "fsl-p2-${k}" => {
        display_name             = "avd-metric-alert-fileShareLowSpace-[${upper(local.env)}]-P2-${share.share_name}"
        scopes                   = ["${share.storage_account_id}/fileServices/default"]
        description              = "File share ${share.share_name} space has dropped below threshold 15% headroom."
        severity                 = 3
        frequency                = "PT1H"
        window_size              = "PT6H"
        enabled                  = local.alerts_enabled
        auto_mitigate            = true
        target_resource_type     = "Microsoft.Storage/storageAccounts/fileServices"
        target_resource_location = local.location
        action_group_keys        = ["devices_lab"]
        criteria = {
          metric_namespace = "microsoft.storage/storageaccounts/fileservices"
          metric_name      = "FileCapacity"
          aggregation      = "Average"
          operator         = "GreaterThanOrEqual"
          threshold        = floor(share.quota_gb * 0.85 * 1073741824)
          dimensions = [{
            name     = "FileShare"
            operator = "Include"
            values   = [share.share_name]
          }]
        }
      }
    },
    {
      for k, share in var.alert_fslogix_file_shares :
      "fsl-p1-${k}" => {
        display_name             = "avd-metric-alert-fileShareLowSpace-[${upper(local.env)}]-P1-${share.share_name}"
        scopes                   = ["${share.storage_account_id}/fileServices/default"]
        description              = "File share ${share.share_name} space has dropped below threshold 5% headroom."
        severity                 = 2
        frequency                = "PT1H"
        window_size              = "PT6H"
        enabled                  = local.alerts_enabled
        auto_mitigate            = true
        target_resource_type     = "Microsoft.Storage/storageAccounts/fileServices"
        target_resource_location = local.location
        action_group_keys        = ["devices_lab"]
        criteria = {
          metric_namespace = "microsoft.storage/storageaccounts/fileservices"
          metric_name      = "FileCapacity"
          aggregation      = "Average"
          operator         = "GreaterThanOrEqual"
          threshold        = floor(share.quota_gb * 0.95 * 1073741824)
          dimensions = [{
            name     = "FileShare"
            operator = "Include"
            values   = [share.share_name]
          }]
        }
      }
    },
  )

  # Reader + APR scopes = mult + pers + broker (legacy v_allsubs)
  alert_scope_subscriptions = merge(
    var.alert_mult_subscription_ids,
    var.alert_pers_subscription_ids,
    var.alert_broker_subscription_ids,
  )
}

# Reader on each monitored subscription for ARG / cross-resource queries
resource "azurerm_role_assignment" "alert_uami_reader" {
  for_each = var.enable_alert_uami ? local.alert_scope_subscriptions : {}

  scope                = "/subscriptions/${each.value}"
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.alert_logs[0].principal_id
}

# Legacy APR — RemoveAllActionGroups; enabled only when apr_enabled (pipeline window)
resource "azurerm_monitor_alert_processing_rule_suppression" "apr" {
  for_each = local.alert_scope_subscriptions

  name                = "avd-apr-suppress-rule-${each.key}"
  resource_group_name = azurerm_resource_group.mgmt.name
  scopes              = ["/subscriptions/${each.value}"]
  enabled             = var.apr_enabled
  tags                = module.tags.tags

  dynamic "schedule" {
    for_each = var.apr_enabled ? [1] : []
    content {
      effective_from  = var.apr_effective_from
      effective_until = var.apr_effective_until
      time_zone       = "GMT Standard Time"
    }
  }
}

# Resource Health — Storage / LAW / scheduled query rules (legacy sub-resource-health.bicep)
resource "azurerm_monitor_activity_log_alert" "resource_health" {
  for_each = local.alert_scope_subscriptions

  name                = "avd-activitylog-alert-resource-health-${each.key}"
  resource_group_name = azurerm_resource_group.mgmt.name
  location            = "global"
  scopes              = ["/subscriptions/${each.value}"]
  description         = "Resource Health alert within ${each.key}"
  enabled             = local.alerts_enabled
  tags                = module.tags.tags

  criteria {
    category = "ResourceHealth"
    resource_types = [
      "microsoft.storage/storageaccounts",
      "microsoft.operationalinsights/workspaces",
      "microsoft.insights/scheduledqueryrules",
    ]

    resource_health {
      current  = ["Degraded", "Unavailable"]
      previous = ["Available"]
      reason   = ["Unknown", "PlatformInitiated"]
    }
  }

  action {
    action_group_id = module.management.action_group_ids["devices_lab"]
  }
}

# Service Health P1 — core platform services (legacy sub-service-health.bicep)
resource "azurerm_monitor_activity_log_alert" "service_health_p1" {
  for_each = local.alert_scope_subscriptions

  name                = "avd-activitylog-alert-P1-service-health-${each.key}"
  resource_group_name = azurerm_resource_group.mgmt.name
  location            = "global"
  scopes              = ["/subscriptions/${each.value}"]
  description         = "Priority 1 Service Health alert within ${each.key}"
  enabled             = local.alerts_enabled
  tags                = module.tags.tags

  criteria {
    category = "ServiceHealth"

    service_health {
      locations = ["uksouth", "global"]
      services = [
        "Virtual Machines",
        "Virtual Network",
        "Windows Virtual Desktop",
        "Storage",
        "Network Infrastructure",
        "ExpressRoute \\ ExpressRoute Circuits",
        "ExpressRoute \\ ExpressRoute Gateways",
        "Azure Active Directory",
        "Azure Resource Manager",
        "Azure Firewall",
        "Key Vault",
      ]
    }
  }

  action {
    action_group_id = module.management.action_group_ids["devices_lab"]
  }
}

# Service Health P2 — monitoring / devops adjacent (legacy sub-service-health-p2.bicep)
resource "azurerm_monitor_activity_log_alert" "service_health_p2" {
  for_each = local.alert_scope_subscriptions

  name                = "avd-activitylog-alert-P2-service-health-${each.key}"
  resource_group_name = azurerm_resource_group.mgmt.name
  location            = "global"
  scopes              = ["/subscriptions/${each.value}"]
  description         = "Priority 2 Service Health alert within ${each.key}"
  enabled             = local.alerts_enabled
  tags                = module.tags.tags

  criteria {
    category = "ServiceHealth"

    service_health {
      locations = ["uksouth", "global"]
      services = [
        "Action Groups",
        "Activity Logs & Alerts",
        "Automation",
        "Azure Blueprints",
        "Azure Devops",
        "Azure DevOps \\ Artifacts",
        "Azure DevOps \\ Pipelines",
        "Azure DevOps \\ Repos",
        "Azure Monitor",
        "Azure Policy",
        "Azure Reservations",
        "Azure Sentinel",
        "Cloud Shell",
        "Log Analytics",
        "Logic Apps",
        "Microsoft Azure Portal",
        "Microsoft Defender for Cloud",
        "Microsoft Graph",
        "Network Watcher",
        "Virtual Machine Scale Sets",
      ]
    }
  }

  action {
    action_group_id = module.management.action_group_ids["devices_lab"]
  }
}
