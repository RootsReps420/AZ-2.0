variable "resource_group_name" {
  description = "Name of the resource group into which resources are deployed."
  type        = string
}

variable "location" {
  description = "Azure region for resources (e.g. \"uksouth\"). Never hardcode region."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming inputs (passed through to modules/naming)
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription / landing-zone segment used by the naming module (e.g. \"vdi\", \"conn\")."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment segment used in names and tags (e.g. \"dev\", \"int\", \"prd\")."
  type        = string
}

variable "description" {
  description = "Description segment for the naming module (workload-specific label)."
  type        = string
  default     = ""
}

variable "unique_id" {
  description = "Uniqueness / instance id segment for the naming module (e.g. \"01\")."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Tags - caller supplies merged map from modules/tags
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Merged tag map from modules/tags (pass module.tags.tags from the caller). Applied to all resources."
  type        = map(string)
  default     = {}
}