# environments/int/avd

Azure Virtual Desktop objects for **int**: multisession, personal, and privileged host pools.

## Multisession (30 pools)

- Per-pool max sessions / Remote Desktop Protocol / validation / description
- Scheduled agent updates Saturday 01:00 GMT
- Registration token ~175 hours
- Scaling plans with `spExclude` + Log Analytics `allLogs`
- Workspace / application-group friendly names from legacy

## Personal (10 pools)

Catalog from `PERS-General` + `PERS-Packaging`: Personal / Direct / Persistent / max 9999 / start VM on connect. Workspace friendly name `RTL-DESKTOPS`. Toggle with `enable_pers_host_pools`.

## Privileged (1 pool)

`PRIV-General` pool `001-01` (copypaste Remote Desktop Protocol). Workspace `PRIV-DESKTOPS`. Toggle with `enable_priv_host_pools`.

## Other

- Compute gallery + image definitions; Packer custom role via tfvars
- Windows Virtual Desktop Power On Off Contributor hook (AVD + optional lab subscriptions)
- Multisession data collection rules / custom tables (VM associations stay PowerShell)

```bash
terraform init -backend=false
terraform validate
```
