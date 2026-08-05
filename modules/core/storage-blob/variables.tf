variable "name" {
  description = "Descriptor for the storage account naming pattern."
  type        = string
  default     = ""
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "environment" {
  type = string
}

variable "unique_id" {
  type    = string
  default = ""
}

variable "name_override" {
  description = "Optional exact storage account name (bypasses naming module)."
  type        = string
  default     = null
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_kind" {
  type    = string
  default = "StorageV2"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "public_network_access_enabled" {
  description = "Legacy PERS blob uses Deny ACL with public access enabled (no private endpoint)."
  type        = bool
  default     = true
}

variable "shared_access_key_enabled" {
  description = "Legacy allowSharedKeyAccess false — keys disabled; use Azure AD."
  type        = bool
  default     = false
}

variable "default_to_oauth_authentication" {
  description = "Prefer Azure AD for data-plane auth (pairs with shared_access_key_enabled=false)."
  type        = bool
  default     = true
}

variable "network_rules" {
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
