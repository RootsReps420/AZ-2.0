variable "azure_subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "environment" {
  type    = string
  default = "int"
}

variable "subscription_code" {
  type    = string
  default = "vdi"
}

variable "law_id" {
  description = "Log Analytics workspace ID from int/mgmt (optional diagnostics)."
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
  description = <<-EOT
    RBAC on the gallery. Packer build MSI uses the legacy custom role GUID
    (int: 2500ba2b-6673-4e4c-8b04-9ad0374a7922 from gallery/int/environment.json).
    Set principal_id to the MSI object ID (lookup build-bp-int-vdi-mgmt-msi).
  EOT
  type = map(object({
    principal_id         = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
  }))
  default = {}
}

variable "wvd_power_on_off_principal_id" {
  description = "Tenant object ID of Windows Virtual Desktop first-party SP (AppId 9cdead84-a844-4324-93f2-b2e6bb768d07). Null skips. Assigned on AVD sub + optional lab subs."
  type        = string
  default     = null
}

variable "wvd_power_on_off_lab_subscription_ids" {
  description = "Extra subscription GUIDs for Desktop Virtualization Power On Off Contributor (legacy mult lab subs). Keys arbitrary."
  type        = map(string)
  default     = {}
}

variable "keyvault_unique_id" {
  description = "7-char globally unique Key Vault name suffix (TDA). Set via tfvars — never hardcode per env in shared modules."
  type        = string
  default     = "avdint1"
}

variable "enable_pers_host_pools" {
  description = "When true, deploy PERS host pools from catalog (or var.pers_host_pools override). Set false to skip PERS AVD objects."
  type        = bool
  default     = true
}

variable "pers_host_pools" {
  description = "Override PERS host-pool map. Empty + enable_pers_host_pools = use catalog in pers_pools.tf (10 pools from PERS-General + Packaging)."
  type = map(object({
    assignment_type      = optional(string, "Direct")
    rdp_persona          = optional(string, "standard") # standard | copypaste | smartcard | print-copypaste
    description          = optional(string)
    friendly_name        = optional(string)
    validate_environment = optional(bool, false)
  }))
  default = {}
}
