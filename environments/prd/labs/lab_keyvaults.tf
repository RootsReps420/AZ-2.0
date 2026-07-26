# Lab Key Vaults — Multi (2) + Personal (12) + Priv (1) = 15 when priv_spokes set.
# Premium, RBAC, Deny network ACLs + AVD/Agents service-endpoint allow list.
# Naming uses TDA-style unique ids (legacy embedded subscription GUID segment 2
# is not available in the single-subscription Terraform cutover).

data "azurerm_client_config" "current" {}

locals {
  lab_keyvault_priv = {
    for lab, _ in var.priv_spokes : lab => {
      unique_id = "vlb${lab}1"
      subnet_ids = compact([
        module.spoke_priv[lab].subnet_ids["AVDSubnet"],
        var.agents_subnet_id,
      ])
    }
  }

  lab_keyvault_mult = {
    "01a" = {
      unique_id = "mlb01a1"
      subnet_ids = compact(concat(
        values(module.spoke_msh["01a"].subnet_ids),
        [var.agents_subnet_id],
      ))
    }
    "01b" = {
      unique_id = "mlb01b1"
      subnet_ids = compact(concat(
        values(module.spoke_msh["01b"].subnet_ids),
        [var.agents_subnet_id],
      ))
    }
  }

  lab_keyvault_pers = {
    for lab, _ in var.pers_spokes : lab => {
      unique_id = "plb${lab}1"
      subnet_ids = compact([
        module.spoke_pers[lab].subnet_ids["AVDSubnet"],
        var.agents_subnet_id,
      ])
    }
  }

  # CMK keys for FSLogix STAs — land on the Multi lab vault for that STA's lab
  fslogix_cmk_keys_by_mult_lab = {
    for lab in keys(local.lab_keyvault_mult) : lab => {
      for sta_key, sta in local.fslogix_stas :
      "${local.fslogix_legacy_sta_name[sta_key]}-sa-cmk" => {
        key_type = "RSA"
        key_size = 4096
        key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      }
      if sta.lab == lab
    }
  }
}

module "keyvault_mult" {
  for_each = var.enable_lab_keyvaults ? local.lab_keyvault_mult : {}
  source   = "../../../modules/core/keyvault"

  name                = "vdi"
  resource_group_name = azurerm_resource_group.mult.name
  location            = local.location
  environment         = local.env
  unique_id           = each.value.unique_id

  sku_name                      = "premium"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = true

  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = each.value.subnet_ids
  }

  # Terraform principal needs Crypto Officer to create CMK keys at apply time
  role_assignments = merge(
    {
      terraform_crypto_officer = {
        role_definition_name = "Key Vault Crypto Officer"
        principal_id         = data.azurerm_client_config.current.object_id
      }
    },
    {
      for sta_key, sta in local.fslogix_stas :
      "fslogix_cmk_${sta_key}" => {
        role_definition_name = "Key Vault Crypto Service Encryption User"
        principal_id         = azurerm_user_assigned_identity.fslogix[sta_key].principal_id
      }
      if sta.lab == each.key && var.enable_fslogix
    }
  )

  keys = var.enable_fslogix ? local.fslogix_cmk_keys_by_mult_lab[each.key] : {}

  tags = module.tags_mult.tags
}

module "keyvault_pers" {
  for_each = var.enable_lab_keyvaults ? local.lab_keyvault_pers : {}
  source   = "../../../modules/core/keyvault"

  name                = "vdi"
  resource_group_name = azurerm_resource_group.pers.name
  location            = local.location
  environment         = local.env
  unique_id           = each.value.unique_id

  sku_name                      = "premium"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = true

  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = each.value.subnet_ids
  }

  tags = module.tags_pers.tags
}

module "keyvault_priv" {
  for_each = var.enable_lab_keyvaults ? local.lab_keyvault_priv : {}
  source   = "../../../modules/core/keyvault"

  name                = "vdi"
  resource_group_name = azurerm_resource_group.priv[0].name
  location            = local.location
  environment         = local.env
  unique_id           = each.value.unique_id

  sku_name                      = "premium"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = true

  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = each.value.subnet_ids
  }

  tags = module.tags_priv.tags
}
