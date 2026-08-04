# environments/igmf/mgmt

Log Analytics, monitoring alerts, and the management spoke for the **IGMF**
sandbox (ignitemyfire.co.uk). Agent VMSS stays PowerShell.

Forked from `environments/int/mgmt` with sandbox identity (Azure DNS, null bank
devops SP, sandbox tags).

| Item | CIDR | Notes |
|---|---|---|
| Management VNet / AgentsSubnet | `10.170.139.192/26` | Same as int — isolated tenant |

## Observability

- Log Analytics workspace (retention 30; resource-only permissions true)
- DCE + thin Insights DCR (full MSH set lives in `avd`)
- Action group + alert UAMI shells (alerts **enabled** only when `environment == "prd"` — disabled under `igmf`)
- Scheduled query (AVD log) alert **resources are skipped** under IGMF — Azure rejects create on a LAW with no WVD* tables yet. Restore via `scheduled_query_alerts = local.scheduled_query_alerts` in `main.tf` after AVD/tables exist.

## Inputs to wire at deploy

- `hub01_id`, `hub01_firewall_private_ip` — from `igmf/connectivity`
- Leave `devops_vm_contributor_principal_id = null`

```bash
terraform init -backend=false
terraform validate
```
