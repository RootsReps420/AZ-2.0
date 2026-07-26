# environments/prd/mgmt

Log Analytics, monitoring alerts, and the management spoke for **prd**. Agent virtual machine scale sets stay PowerShell.

| Item | CIDR | Source |
|---|---|---|
| Management VNet / AgentsSubnet | `10.170.241.64/26` | VERIFIED `net_mgmt_*` in `params/prd/config.yml` |

## Observability

- Log Analytics workspace (retention 30; resource-only permissions **false** for prd)
- Data collection endpoint + thin Insights data collection rule (full multisession rule set lives in `avd`)
- Action group `devices_lab` (Devices Lab email)
- Alert managed identity `custom-log-alerts-msi` + Reader on scoped subscriptions
- Scheduled query / metric / activity-log alerts (**enabled** in prd)
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
