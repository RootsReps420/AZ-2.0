output "data_collection_endpoint_id" {
  value = azurerm_monitor_data_collection_endpoint.this.id
}

output "dcr_main_id" {
  value = azurerm_monitor_data_collection_rule.main.id
}

output "dcr_insights_id" {
  value = azurerm_monitor_data_collection_rule.insights.id
}

output "dcr_fsl_id" {
  value = azurerm_monitor_data_collection_rule.fsl.id
}

output "dcr_wss_id" {
  value = azurerm_monitor_data_collection_rule.wss.id
}

output "dcr_ids" {
  description = "Map of logical name -> data collection rule resource ID (for VM association scripts)."
  value = {
    main     = azurerm_monitor_data_collection_rule.main.id
    insights = azurerm_monitor_data_collection_rule.insights.id
    fsl      = azurerm_monitor_data_collection_rule.fsl.id
    wss      = azurerm_monitor_data_collection_rule.wss.id
  }
}
