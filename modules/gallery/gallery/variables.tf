variable "name" {
  description = "Descriptor for the compute gallery (e.g. \"avd\"). Used as the description segment when generating the name via modules/naming."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group into which the gallery is deployed."
  type        = string
}

variable "location" {
  description = "Azure region for the gallery."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming inputs
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription/landing-zone segment used to name the gallery (e.g. \"vdi\")."
  type        = string
}

variable "environment" {
  description = "Environment segment used to name the gallery (e.g. \"dev\", \"prod\")."
  type        = string
}

variable "unique_id" {
  description = "Optional uniqueness/instance suffix used when naming the gallery (e.g. \"01\")."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Gallery
# ---------------------------------------------------------------------------

variable "description" {
  description = "Free-text description of the gallery."
  type        = string
  default     = null
}

variable "role_assignments" {
  description = <<-EOT
    RBAC on the gallery. Use role_definition_name for built-in roles, or
    role_definition_id for legacy custom Packer roles (GUID only; scoped at apply).
  EOT
  type = map(object({
    principal_id         = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string) # GUID of custom role definition
  }))
  default = {}

  validation {
    condition = alltrue([
      for a in values(var.role_assignments) :
      (a.role_definition_name != null) != (a.role_definition_id != null)
    ])
    error_message = "Each gallery role assignment must set exactly one of role_definition_name or role_definition_id."
  }
}

variable "tags" {
  description = "Merged tag map (output of modules/tags) applied to the gallery."
  type        = map(string)
  default     = {}
}
