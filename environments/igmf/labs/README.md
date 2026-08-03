# environments/igmf/labs

Personal, privileged, and multisession lab spokes for the **IGMF** sandbox
(ignitemyfire.co.uk). Session hosts stay PowerShell.

Forked from `environments/int/labs`. Spoke CIDRs reuse int ranges (isolated
tenant). Example tfvars turn off FSLogix and PERS blobs for a thinner smoke
test; set `enable_fslogix` / `enable_pers_blob` true when you want parity.

## Inputs to wire at deploy

- `hub01_id`, `hub02_id`, `hub01_firewall_private_ip` — from `igmf/connectivity`
- `agents_subnet_id`, `law_id` — from `igmf/mgmt` (when enabling storage/KV ACLs or diags)
- DNS must stay Azure (`168.63.129.16`) — never bank `10.19.*`

```bash
terraform init -backend=false
terraform validate
```
