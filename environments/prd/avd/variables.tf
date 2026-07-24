variable "azure_subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "subscription_code" {
  type    = string
  default = "vdi"
}

variable "law_id" {
  description = "Log Analytics workspace ID from prod/mgmt (optional diagnostics)."
  type        = string
  default     = null
}

variable "default_max_session_limit" {
  type    = number
  default = 16
}

variable "mandatory_tags" {
  type = object({
    costCentre             = string
    securityClassification = string
    resourceOwner          = string
    CMDB_AppID             = string
  })
}

variable "gallery_role_assignments" {
  description = "RBAC on the gallery (Packer MSIs need Contributor)."
  type = map(object({
    role_definition_name = string
    principal_id         = string
  }))
  default = {}
}

variable "keyvault_unique_id" {
  description = "7-char globally unique Key Vault name suffix (TDA). Set via tfvars — never hardcode per env in shared modules."
  type        = string
  default     = "avdprd1"
}

variable "pers_host_pools" {
  description = "PERS personal host pools keyed by persona/lab id. Empty = skip PERS AVD objects. Fill from live inventory."
  type = map(object({
    assignment_type = optional(string, "Automatic")
  }))
  default = {}
}
