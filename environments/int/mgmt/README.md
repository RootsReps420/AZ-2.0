# environments/int/mgmt

Log Analytics, monitoring alerts, and the management spoke for **int** (dev test). Agent virtual machine scale sets stay PowerShell.

| Item | CIDR | Source |
|---|---|---|
| Management VNet / AgentsSubnet | `10.170.139.192/26` | VERIFIED `net_mgmt_*` in `params/int/config.yml` |

## Observability

- Log Analytics workspace (retention 30; resource-only permissions **true** for int)
- Data collection endpoint + thin Insights data collection rule (full multisession rule set lives in `avd`)
- Action group `devices_lab` (Devices Lab email)
- Alert managed identity `custom-log-alerts-msi` + Reader on scoped subscriptions
- Scheduled query / metric / activity-log alerts (rules deploy; **enabled** only when environment is `prd`)
- Alert processing rule shell (`apr_enabled` default false)

## Network

- AgentsSubnet network security group deny east-west by subnet CIDR
- `default-to-firewall` route table → Hub01 Azure Firewall (`hub01_firewall_private_ip`)
- Storage + Key Vault service endpoints on AgentsSubnet

## Inputs to wire at deploy

- `hub01_id`, `hub01_firewall_private_ip` — from connectivity
- `alert_mult_subscription_ids` / `alert_pers_subscription_ids` / `alert_broker_subscription_ids`
- `alert_fslogix_file_shares` — from labs storage account outputs (optional)

```bash
terraform init -backend=false
terraform validate
```
