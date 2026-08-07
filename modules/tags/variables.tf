variable "mandatory" {
  description = <<-EOT
    Bank mandatory tags. Typed object so terraform plan fails if any key is missing.
    Keys: costCentre, securityClassification, resourceOwner, CMDB_AppID.
  EOT
  type = object({
    costCentre             = string
    securityClassification = string
    resourceOwner          = string
    CMDB_AppID             = string
  })

  validation {
    condition     = alltrue([for v in values(var.mandatory) : trimspace(v) != ""])
    error_message = "All mandatory tag values must be non-empty."
  }
}

variable "workload" {
  description = <<-EOT
    Workload lane for this module call. Mapped inside this module to the Azure
    workload tag: platform→vdi-platform, pers→vdi-pers, mult→vdi-mult, priv→vdi-priv.
  EOT
  type        = string

  validation {
    condition     = contains(["platform", "pers", "mult", "priv"], var.workload)
    error_message = "workload must be one of: platform, pers, mult, priv."
  }
}

variable "environment" {
  description = "Environment applied as the environment tag (e.g. int, prd, igmf)."
  type        = string

  validation {
    condition     = trimspace(var.environment) != ""
    error_message = "environment must be a non-empty string."
  }
}

variable "region" {
  description = "Region applied as the region tag (e.g. uksouth)."
  type        = string

  validation {
    condition     = trimspace(var.region) != ""
    error_message = "region must be a non-empty string."
  }
}
