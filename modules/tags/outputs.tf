output "tags" {
  description = "Mandatory tag map (bank + platform). Pass directly to the tags argument on Azure resources. Sole tag source for this repo."
  value       = local.tags
}
