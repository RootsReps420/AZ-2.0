# ---------------------------------------------------------------------------
# Gallery — Image Definition
#
# Deploys a single Gallery Image Definition (metadata: OS, publisher/offer/sku,
# generation, architecture, security type). One definition per OS/SKU
# combination — instantiate this module twice from the environment for the PERS
# and MSH base definitions.
#
# Packer publishes image VERSIONS to these definitions; Terraform does not manage
# versions.
# ---------------------------------------------------------------------------

module "image_name" {
  source = "../../naming"

  resource_type   = "image_definition"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = var.name
  unique_id       = var.unique_id
}

resource "azurerm_shared_image" "this" {
  name                = module.image_name.name
  gallery_name        = var.gallery_name
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type            = var.os_type
  hyper_v_generation = var.hyper_v_generation
  architecture       = var.architecture
  specialized        = var.specialized

  # Security type -> provider flags. TrustedLaunch requires generation V2.
  # Only ONE of these may be set (even `false` counts as set and conflicts).
  # Use null to omit — see azurerm_shared_image docs.
  trusted_launch_enabled    = var.security_type == "TrustedLaunch" ? true : null
  confidential_vm_enabled   = var.security_type == "ConfidentialVM" ? true : null
  confidential_vm_supported = var.security_type == "ConfidentialVMSupported" ? true : null

  accelerated_network_support_enabled = var.accelerated_network_support_enabled

  # identifier publisher/offer/sku are Azure SIG metadata — NOT TDA resource names.
  # TDA naming applies to the definition *resource name* via modules/naming above
  # (uks-{sub}-img-{description}).
  #
  # Azure requires a unique (publisher, offer, sku) per gallery and caps sku at
  # 64 chars. Catalog identifier.sku is marketplace source lineage (often reused
  # across BU/variant defs). Use var.name (catalog key, already unique, ≤46) as
  # the gallery sku so we stay under 64 without truncating TDA names.
  identifier {
    publisher = var.identifier.publisher
    offer     = var.identifier.offer
    sku       = var.name
  }

  tags = var.tags
}
