# ---------------------------------------------------------------------------
# Multisession (MSH) Data Collection Rules — legacy vdi_dcr.bicep parity
#
# Creates:
#   - Data Collection Endpoint (custom logs)
#   - Main Windows DCR (Perf + Events)
#   - VM Insights DCR
#   - FSLogix profile custom-log DCR + multfslp_CL table
#   - WSS Agent custom-log DCR + WSS_CL table (legacy created by PERS; we create here so MSH is self-contained)
#
# Associations to session-host VMs stay with the VM / PowerShell path.
# ---------------------------------------------------------------------------

locals {
  # Legacy name suffixes for Custom-Text-* / table (last 8 of dcr name → multfslp)
  fsl_stream_suffix = "multfslp"
  law_dest_ops      = "opsLADestination"
  law_dest_secops   = "secOpsLADestination"
}

resource "azurerm_monitor_data_collection_endpoint" "this" {
  name                          = var.dce_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  public_network_access_enabled = true
  tags                          = var.tags
}

# Custom tables on the Log Analytics workspace (Analytics plan, 30-day retention)
resource "azapi_resource" "table_multfslp" {
  type      = "Microsoft.OperationalInsights/workspaces/tables@2022-10-01"
  name      = "multfslp_CL"
  parent_id = var.log_analytics_workspace_id

  body = {
    properties = {
      totalRetentionInDays = 30
      retentionInDays      = 30
      plan                 = "Analytics"
      schema = {
        name = "multfslp_CL"
        columns = [
          { name = "TimeGenerated", type = "dateTime" },
          { name = "RawData", type = "string" },
          { name = "cleanRawData", type = "string" },
        ]
      }
    }
  }
}

resource "azapi_resource" "table_wss" {
  type      = "Microsoft.OperationalInsights/workspaces/tables@2022-10-01"
  name      = "WSS_CL"
  parent_id = var.log_analytics_workspace_id

  body = {
    properties = {
      totalRetentionInDays = 30
      retentionInDays      = 30
      plan                 = "Analytics"
      schema = {
        name = "WSS_CL"
        columns = [
          { name = "TimeGenerated", type = "dateTime" },
          { name = "Computer", type = "string" },
          { name = "FilePath", type = "string" },
          { name = "RawData", type = "string" },
          { name = "Details", type = "string" },
        ]
      }
    }
  }
}

resource "azurerm_monitor_data_collection_rule" "main" {
  name                = var.dcr_main_name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Windows"
  description         = "${var.dcr_main_name} Data Collection Rule"
  tags                = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = local.law_dest_secops
    }
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = local.law_dest_ops
    }
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = [local.law_dest_secops]
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = [local.law_dest_ops]
  }

  data_sources {
    performance_counter {
      name                          = "perfCountersSource60"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = local.dcr_perf_60
    }

    performance_counter {
      name                          = "perfCountersSource300"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 300
      counter_specifiers            = local.dcr_perf_300
    }

    windows_event_log {
      name           = "eventLogsSource"
      streams        = ["Microsoft-Event"]
      x_path_queries = local.dcr_event_xpaths
    }
  }
}

resource "azurerm_monitor_data_collection_rule" "insights" {
  name                = var.dcr_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "${var.dcr_insights_name} Data Collection Rule"
  tags                = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = local.law_dest_ops
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = [local.law_dest_ops]
  }

  data_flow {
    streams      = ["Microsoft-ServiceMap"]
    destinations = [local.law_dest_ops]
  }

  data_sources {
    performance_counter {
      name                          = "VMInsightsPerfCounters"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
    }

    extension {
      name           = "DependencyAgentDataSource"
      extension_name = "DependencyAgent"
      streams        = ["Microsoft-ServiceMap"]
    }
  }
}

resource "azurerm_monitor_data_collection_rule" "fsl" {
  name                        = var.dcr_fsl_name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  kind                        = "Windows"
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.this.id
  tags                        = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = local.law_dest_ops
    }
  }

  stream_declaration {
    stream_name = "Custom-Text-${local.fsl_stream_suffix}_CL"
    column {
      name = "TimeGenerated"
      type = "datetime"
    }
    column {
      name = "RawData"
      type = "string"
    }
  }

  data_sources {
    log_file {
      name          = "Custom-Text-${local.fsl_stream_suffix}_CL"
      streams       = ["Custom-Text-${local.fsl_stream_suffix}_CL"]
      file_patterns = [var.fsl_log_file_pattern]
      format        = "text"
      settings {
        text {
          record_start_timestamp_format = "ISO 8601"
        }
      }
    }
  }

  data_flow {
    streams       = ["Custom-Text-${local.fsl_stream_suffix}_CL"]
    destinations  = [local.law_dest_ops]
    transform_kql = "source | extend cleanRawData = replace(@'\\x00', '', RawData)"
    output_stream = "Custom-${local.fsl_stream_suffix}_CL"
  }

  depends_on = [azapi_resource.table_multfslp]
}

resource "azurerm_monitor_data_collection_rule" "wss" {
  name                        = var.dcr_wss_name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  kind                        = "Windows"
  description                 = "${var.dcr_wss_name} Data Collection Rule"
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.this.id
  tags                        = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = local.law_dest_ops
    }
  }

  stream_declaration {
    stream_name = "Custom-Text-WSS_CL"
    column {
      name = "TimeGenerated"
      type = "datetime"
    }
    column {
      name = "Computer"
      type = "string"
    }
    column {
      name = "FilePath"
      type = "string"
    }
    column {
      name = "RawData"
      type = "string"
    }
    column {
      name = "Details"
      type = "string"
    }
  }

  data_sources {
    log_file {
      name          = "Custom-Text-WSS_CL"
      streams       = ["Custom-Text-WSS_CL"]
      file_patterns = [var.wss_log_file_pattern]
      format        = "text"
      settings {
        text {
          record_start_timestamp_format = "ISO 8601"
        }
      }
    }
  }

  data_flow {
    streams       = ["Custom-Text-WSS_CL"]
    destinations  = [local.law_dest_ops]
    transform_kql = "source | extend Details = tostring(split(RawData, ':00)]: ')[1])"
    output_stream = "Custom-WSS_CL"
  }

  depends_on = [azapi_resource.table_wss]
}
