variable "name" {
  description = "Descriptor for the storage account (e.g. \"lab01\"). Used as the description segment in the storage name pattern."
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "Name of the resource group into which the storage account is deployed."
  type        = string
}

variable "location" {
  description = "Azure region for the storage account."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming inputs
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription/landing-zone segment (not used by the storage name pattern, kept for module consistency)."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment segment used in the storage name (e.g. \"dev\", \"prod\")."
  type        = string
}

variable "unique_id" {
  description = "Uniqueness id for the storage name. Storage account names are globally unique and capped at 24 chars (lowercase alphanumeric)."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Storage account
# ---------------------------------------------------------------------------

variable "account_tier" {
  description = "Storage account tier. Premium is recommended for FSLogix."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier must be Standard or Premium."
  }
}

variable "account_kind" {
  description = "Storage account kind. FileStorage is required for Premium file shares."
  type        = string
  default     = "FileStorage"
}

variable "account_replication_type" {
  description = "Replication type. One of: LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  type        = string
  default     = "ZRS"
}

variable "min_tls_version" {
  description = "Minimum TLS version for the storage account."
  type        = string
  default     = "TLS1_2"
}

variable "name_override" {
  description = "Optional exact storage account name (bypasses modules/naming). Use for legacy-exact names (24-char alphanumeric)."
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether the account is reachable from public networks. Legacy FSLogix uses Deny ACL + VNet rules with public access enabled (API default); keep true for that model. Set false only with private endpoints."
  type        = bool
  default     = true
}

variable "shared_access_key_enabled" {
  description = "Allow shared key access. Legacy FSLogix sets allowSharedKeyAccess false."
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Double encryption at rest. Legacy requireInfrastructureEncryption true."
  type        = bool
  default     = true
}

variable "smb" {
  description = "Optional Azure Files SMB protocol settings (legacy: Kerberos, AES-256-GCM, SMB3.1.1, multichannel)."
  type = object({
    versions                        = optional(list(string), ["SMB3.1.1"])
    authentication_types            = optional(list(string), ["Kerberos"])
    kerberos_ticket_encryption_type = optional(list(string), ["AES-256"])
    channel_encryption_type         = optional(list(string), ["AES-256-GCM"])
    multichannel_enabled            = optional(bool, true)
  })
  default = null
}

variable "log_analytics_workspace_id" {
  description = "LAW id for file-service diagnostics. Null skips the diagnostic setting."
  type        = string
  default     = null
}

variable "share_soft_delete_days" {
  description = "Soft-delete retention (days) for file shares (1-365)."
  type        = number
  default     = 7

  validation {
    condition     = var.share_soft_delete_days >= 1 && var.share_soft_delete_days <= 365
    error_message = "share_soft_delete_days must be between 1 and 365."
  }
}

# ---------------------------------------------------------------------------
# Identity / auth / network / CMK
# ---------------------------------------------------------------------------

variable "identity_type" {
  description = "Managed identity type for the storage account (e.g. \"SystemAssigned\", \"UserAssigned\"). Null for none."
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "User-assigned identity IDs when identity_type includes UserAssigned."
  type        = list(string)
  default     = null
}

variable "azure_files_authentication" {
  description = <<-EOT
    Identity-based auth for Azure Files. directory_type is one of AADKERB, AADDS, AD.
    For AADKERB, domain_name + domain_guid may be set (legacy p_FSLogixSta); other AD
    fields are required only for directory_type = AD.
  EOT
  type = object({
    directory_type                 = string
    default_share_level_permission = optional(string, "None")
    active_directory = optional(object({
      domain_name         = string
      domain_guid         = string
      domain_sid          = optional(string)
      forest_name         = optional(string)
      netbios_domain_name = optional(string)
      storage_sid         = optional(string)
    }))
  })
  default = null
}

variable "network_rules" {
  description = "Optional network rules for the storage account."
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "customer_managed_key" {
  description = "Optional CMK encryption. Requires a user-assigned identity with access to the key."
  type = object({
    key_vault_key_id          = string # full Key Vault key id (replaces deprecated key_vault_id + key_name + key_version)
    user_assigned_identity_id = string
  })
  default = null
}

variable "shares" {
  description = "File shares keyed by share name. quota_gb is the share size in GB; access_tier is optional."
  type = map(object({
    quota_gb    = number
    access_tier = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Merged tag map (output of modules/tags) applied to the storage account."
  type        = map(string)
  default     = {}
}
