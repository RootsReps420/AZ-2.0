# modules/core/storage-fslogix

Deploys the **FSLogix profile storage** for a lab: a storage account (Premium
FileStorage by default) with SMB file service settings, identity-based
authentication, and one or more file shares.

Labs pass a `shares` map of `profiles-{bu}-{pool}` (+ `redirection`). INT uses
RTL 100 GB quotas; PRD uses legacy hostpool JSON quotas — see
`environments/*/labs/fslogix_shares.tf`.

## Azure resources

- `azurerm_storage_account` (with `share_properties` / file service settings)
- `azurerm_storage_share` (per `shares`)
- `azurerm_storage_account_customer_managed_key` (when `customer_managed_key` set)

## Naming

Uses the TDA Storage Account exception pattern `{region}{env}{abbr}{desc}{id}`
(no separators, lowercase alphanumeric, <= 24 chars). Storage account names are
globally unique.

## Auth

`azure_files_authentication.directory_type` is one of `AADKERB` (default in the
example), `AADDS`, or `AD` (supply `active_directory` for on-prem AD DS).

## Outputs

`storage_account_id`, `storage_account_name`, `primary_file_host`,
`file_share_names`, `file_share_urls`.

See [`examples/basic`](examples/basic) for usage.
