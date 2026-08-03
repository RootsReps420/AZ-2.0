# PRIV toggles kept separate so terraform-ls indexes them even if complex PERS
# object types in variables.tf fail enhanced validation.
variable "enable_priv_host_pools" {
  description = "When true, deploy PRIV host pools from catalog (or var.priv_host_pools override)."
  type        = bool
  default     = true
}

variable "priv_host_pools" {
  description = "Override PRIV host-pool map. Empty + enable_priv_host_pools = use catalog (PRIV-General 001-01)."
  type = map(object({
    assignment_type      = optional(string, "Direct")
    rdp_persona          = optional(string, "copypaste")
    description          = optional(string)
    friendly_name        = optional(string)
    validate_environment = optional(bool, false)
  }))
  default = {}
}
