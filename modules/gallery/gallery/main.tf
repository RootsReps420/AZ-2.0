# ---------------------------------------------------------------------------
# Gallery — Azure Compute Gallery
#
# Deploys one Azure Compute Gallery per region, plus any RBAC role assignments
# (the Packer build MSI needs Contributor on the gallery to publish image
# versions).
#
# Terraform manages the gallery and (via modules/gallery/image-definition) the
# image DEFINITIONS only. Image VERSIONS — PERS (stripped-down + Proxy baked in)
# and MSH (base image + per-BU app artefacts) — are built and published by the
# Packer pipelines, not Terraform.
#
# Note: Azure Compute Gallery names disallow hyphens, so the naming module emits
# an underscore-joined name for this resource type.
# ---------------------------------------------------------------------------

module "gallery_name" {
  source = "../../naming"

  resource_type   = "compute_gallery"
  location        = var.location
  subscription_id = var.subscription_id
  environment     = var.environment
  description     = var.name
  unique_id       = var.unique_id
}

resource "azurerm_shared_image_gallery" "this" {
  name                = module.gallery_name.name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = var.description
  tags                = var.tags
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = azurerm_shared_image_gallery.this.id
  role_definition_name = each.value.role_definition_name
  role_definition_id = each.value.role_definition_id != null ? (
    startswith(each.value.role_definition_id, "/subscriptions/")
    ? each.value.role_definition_id
    : "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${each.value.role_definition_id}"
  ) : null
  principal_id = each.value.principal_id
}

data "azurerm_client_config" "current" {}
