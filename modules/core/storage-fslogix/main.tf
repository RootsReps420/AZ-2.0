# ---------------------------------------------------------------------------
# Core — FSLogix Profile Storage (per lab)
#
# Deploys the FSLogix profile storage for a lab:
#   - Storage account (Premium FileStorage by default) with SMB file service
#     settings and identity-based authentication (AADKERB by default)
#   - One or more file shares
#   - Optional customer-managed-key encryption
#
# The storage account name uses the TDA Storage Account exception pattern
# ({region}{env}{abbr}{desc}{id}, no separators, <= 24 chars) via modules/naming.
# ---------------------------------------------------------------------------

module "sta_name" {
  source = "../../naming"

  resource_type   = "fslogix_storage_account"
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

  https_traffic_only_enabled        = true
  min_tls_version                   = var.min_tls_version
  public_network_access_enabled     = var.public_network_access_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : [var.identity_type]
    content {
      type         = identity.value
      identity_ids = var.identity_ids
    }
  }

  dynamic "azure_files_authentication" {
    for_each = var.azure_files_authentication == null ? [] : [var.azure_files_authentication]
    content {
      directory_type                 = azure_files_authentication.value.directory_type
      default_share_level_permission = azure_files_authentication.value.default_share_level_permission

      dynamic "active_directory" {
        for_each = azure_files_authentication.value.active_directory == null ? [] : [azure_files_authentication.value.active_directory]
        content {
          domain_name         = active_directory.value.domain_name
          domain_guid         = active_directory.value.domain_guid
          domain_sid          = active_directory.value.domain_sid
          forest_name         = active_directory.value.forest_name
          netbios_domain_name = active_directory.value.netbios_domain_name
          storage_sid         = active_directory.value.storage_sid
        }
      }
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules == null ? [] : [var.network_rules]
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  share_properties {
    retention_policy {
      days = var.share_soft_delete_days
    }

    dynamic "smb" {
      for_each = var.smb == null ? [] : [var.smb]
      content {
        versions                        = smb.value.versions
        authentication_types            = smb.value.authentication_types
        kerberos_ticket_encryption_type = smb.value.kerberos_ticket_encryption_type
        channel_encryption_type         = smb.value.channel_encryption_type
        multichannel_enabled            = smb.value.multichannel_enabled
      }
    }
  }

  tags = var.tags
}

# Optional customer-managed-key encryption. Requires the account identity to
# have access to the key.
resource "azurerm_storage_account_customer_managed_key" "this" {
  count = var.customer_managed_key == null ? 0 : 1

  storage_account_id        = azurerm_storage_account.this.id
  key_vault_key_id          = var.customer_managed_key.key_vault_key_id
  user_assigned_identity_id = var.customer_managed_key.user_assigned_identity_id
}

resource "azurerm_storage_share" "this" {
  for_each = var.shares

  name               = each.key
  storage_account_id = azurerm_storage_account.this.id
  quota              = each.value.quota_gb
  access_tier        = each.value.access_tier
}

# Legacy sa_fslogix: StorageRead/Write/Delete + Transaction → LAW (AzureDiagnostics)
resource "azurerm_monitor_diagnostic_setting" "file" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${azurerm_storage_account.this.name}-filediagnostics"
  target_resource_id         = "${azurerm_storage_account.this.id}/fileServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }
  enabled_metric {
    category = "Transaction"
  }
}
