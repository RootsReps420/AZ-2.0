# environments/igmf/avd

Azure Virtual Desktop objects for the **IGMF** sandbox (ignitemyfire.co.uk):
multisession, personal, and privileged host pools.

Forked from `environments/int/avd`. Full catalogs are present; first smoke can
set `enable_pers_host_pools = false` / `enable_priv_host_pools = false` in
tfvars to cut cost. Leave Packer / WVD principal assignments unset until you
have IGMF identities.

## Other

- Compute gallery + image definitions
- Multisession data collection rules when `law_id` is set (from `igmf/mgmt`)
- Session hosts stay PowerShell

```bash
terraform init -backend=false
terraform validate
```
