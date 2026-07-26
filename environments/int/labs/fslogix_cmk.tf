# Per-FSLogix-STA user-assigned managed identity for customer-managed key encryption.
# Legacy name: {storageAccountName}-msi

resource "azurerm_user_assigned_identity" "fslogix" {
  for_each = var.enable_fslogix ? local.fslogix_stas : {}

  name                = "${local.fslogix_legacy_sta_name[each.key]}-msi"
  resource_group_name = azurerm_resource_group.mult.name
  location            = local.location
  tags                = module.tags_mult.tags
}
