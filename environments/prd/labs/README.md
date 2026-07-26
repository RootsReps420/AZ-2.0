# environments/prd/labs

Personal, privileged, and multisession lab spokes for **prd**. Session hosts stay PowerShell.

## Verified PRD CIDRs (legacy `config.yml`)

| Spoke | CIDR | Source |
|---|---|---|
| Privileged 01a | VNet `10.170.228.0/22`, AVD `10.170.228.0/23` | `net_lab_core_priv_01a_*` |
| Personal 01a–01h, 01k | `/21` from `10.170.160.0` … `10.170.232.0` | platform `prd/config.yml` |
| Personal 01i | `10.170.224.0/22` | Robotics |
| Personal 01j | `10.170.241.0/27` | P&D (adjacent to management `241.64/26`) |
| Personal 01l | `10.170.248.0/21` | blocks Hub02 using `248/24` |
| Multisession 01a | `10.218.16.0/21` (+ named subnets) | pers `prd/config.yml` |
| Multisession 01b | `10.218.24.0/21` (+ named subnets) | pers `prd/config.yml` |

## Route tables

- **Personal / Privileged:** `default-to-firewall` (`0.0.0.0/0` ? Hub01 Azure Firewall) via `hub01_firewall_private_ip`
- **Multisession:** three-rule dual-hub user-defined routes
- Legacy privileged local Azure Firewall is **not** redeployed (post–Virtual WAN; Hub01 is the next hop)

## FSLogix profile storage

- **10 storage accounts** with legacy names and per-business-unit share placement
- Production quotas from host-pool JSON (includes `profiles-005-01` = 51200 GB)
- Deny network rules, Kerberos Server Message Block settings, customer-managed keys

## Lab Key Vaults / personal blob storage

15 Premium Key Vaults when privileged is enabled (2 Multi + 12 Personal + 1 Privileged); 12 personal blob accounts (`uksprdvdipersblb{lab}`).

## Inputs to wire at deploy

- `agents_subnet_id` — management Agents subnet
- `law_id` — Log Analytics workspace for file diagnostics (optional)
- Set `priv_spokes = {}` to skip privileged lab resources

```bash
terraform init -backend=false
terraform validate
```
