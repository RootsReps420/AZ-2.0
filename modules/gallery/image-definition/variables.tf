variable "name" {
  description = "Descriptor for the image definition (e.g. \"pers-win11\", \"msh-win11-base\"). Used as the description segment when generating the name via modules/naming."
  type        = string
}

variable "gallery_name" {
  description = "Name of the compute gallery this definition belongs to. Output gallery_name from modules/gallery/gallery."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that holds the gallery."
  type        = string
}

variable "location" {
  description = "Azure region for the image definition."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming inputs
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription/landing-zone segment used to name the definition (e.g. \"vdi\")."
  type        = string
}

variable "environment" {
  description = "Environment segment used to name the definition (e.g. \"dev\", \"prod\")."
  type        = string
}

variable "unique_id" {
  description = "Optional uniqueness/instance suffix used when naming the definition (e.g. \"01\")."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Image definition
# ---------------------------------------------------------------------------

variable "os_type" {
  description = "OS type of the image. One of: Windows, Linux."
  type        = string
  default     = "Windows"

  validation {
    condition     = contains(["Windows", "Linux"], var.os_type)
    error_message = "os_type must be Windows or Linux."
  }
}

variable "identifier" {
  description = <<-EOT
    Image identifier (publisher, offer, sku). Catalog `sku` is the marketplace
    source lineage; the module appends the definition name to `sku` at apply time
    because Azure Compute Gallery requires a unique publisher/offer/sku per
    gallery (duplicate triples return 409 OperationNotAllowed).
  EOT
  type = object({
    publisher = string
    offer     = string
    sku       = string
  })
}

variable "hyper_v_generation" {
  description = "Hyper-V generation. V2 is required for TrustedLaunch/ConfidentialVM."
  type        = string
  default     = "V2"

  validation {
    condition     = contains(["V1", "V2"], var.hyper_v_generation)
    error_message = "hyper_v_generation must be V1 or V2."
  }
}

variable "architecture" {
  description = "CPU architecture. One of: x64, Arm64."
  type        = string
  default     = "x64"

  validation {
    condition     = contains(["x64", "Arm64"], var.architecture)
    error_message = "architecture must be x64 or Arm64."
  }
}

variable "security_type" {
  description = "Security type. One of: Standard, TrustedLaunch, ConfidentialVM, ConfidentialVMSupported. TrustedLaunch/ConfidentialVM require hyper_v_generation V2."
  type        = string
  default     = "TrustedLaunch"

  validation {
    condition     = contains(["Standard", "TrustedLaunch", "ConfidentialVM", "ConfidentialVMSupported"], var.security_type)
    error_message = "security_type must be one of: Standard, TrustedLaunch, ConfidentialVM, ConfidentialVMSupported."
  }
}

variable "specialized" {
  description = "Whether the image is specialized (already generalized = false)."
  type        = bool
  default     = false
}

variable "accelerated_network_support_enabled" {
  description = "Whether the image supports accelerated networking."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Merged tag map (output of modules/tags) applied to the image definition."
  type        = map(string)
  default     = {}
}
