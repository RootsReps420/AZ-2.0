# PERS blob storage accounts — legacy labCorePersistent rsg_storage
# Name: uks{env}vdipersblb{lab} (e.g. uksintvdipersblb01a)
# StorageV2 Standard_LRS; Deny ACL + AVDSubnet + AgentsSubnet; no CMK.

module "storage_pers_blob" {
  for_each = var.enable_pers_blob ? var.pers_spokes : {}
  source   = "../../../modules/core/storage-blob"

  name                = "vdipersblb"
  resource_group_name = azurerm_resource_group.pers.name
  location            = local.location
  subscription_id     = ""
  environment         = local.env
  unique_id           = each.key
  name_override       = "uks${local.env}vdipersblb${each.key}"

  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  account_replication_type      = "LRS"
  public_network_access_enabled = true
  shared_access_key_enabled     = false

  network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    virtual_network_subnet_ids = compact([
      module.spoke_pers[each.key].subnet_ids["AVDSubnet"],
      var.agents_subnet_id,
    ])
  }

  tags = module.tags_pers.tags
}
