# TODO(deploy): supply the real connectivity/global subscription GUID via tfvars.
variable "azure_subscription_id" {
  description = "Azure subscription GUID the connectivity/global resources are deployed into."
  type        = string
}

variable "subscription_code" {
  description = "Short subscription / landing-zone code used in resource names (e.g. \"conn\")."
  type        = string
  default     = "conn"
}

variable "environment" {
  description = "Environment segment for the global resources. TDA consumer environments are dev/ppd/prd (TDA §4)."
  type        = string
  default     = "prd" # was "prod": TDA §4 uses "prd"
}

variable "location" {
  description = "Home region for the global Virtual WAN."
  type        = string
  default     = "uksouth"
}

# TODO(deploy): supply real values via tfvars (costCentre, securityClassification, resourceOwner, CMDB_AppID).
variable "mandatory_tags" {
  description = "Mandatory bank tags applied to all global resources (see modules/tags)."
  type = object({
    costCentre             = string
    securityClassification = string
    resourceOwner          = string
    CMDB_AppID             = string
  })
}
