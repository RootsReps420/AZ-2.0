# ---------------------------------------------------------------------------
# Core — general-purpose blob storage (PERS lab blob accounts)
#
# StorageV2 Standard_LRS by default. Supports Deny network ACLs + optional
# exact name override for legacy-parity names.
# ---------------------------------------------------------------------------

module "sta_name" {
  source = "../../naming"

  resource_type   = "blob_storage_account"
  location        = var.location
  environment     = var.environment
  subscription_id = var.subscription_id
  description     = var.name
  unique_id       = var.unique_id
}

resource "azurerm_storage_account" "this" {
  name                = coalesce(var.name_override, module.sta_name.name)
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_kind             = var.account_kind
  account_replication_type = var.account_replication_type

  https_traffic_only_enabled    = true
  min_tls_version               = var.min_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  shared_access_key_enabled     = var.shared_access_key_enabled
  allow_nested_items_to_be_public = false

  dynamic "network_rules" {
    for_each = var.network_rules == null ? [] : [var.network_rules]
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}
