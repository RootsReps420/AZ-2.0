# environments/int/labs

Personal, privileged, and multisession lab spokes for **int**. Session hosts stay PowerShell.

## Verified INT CIDRs (legacy `config.yml`)

| Spoke | CIDR | Source |
|---|---|---|
| Privileged 01a | VNet `10.170.137.0/24`, AVD `10.170.137.0/25` | `net_lab_core_priv_01a_*` |
| Personal 01a–01l | `10.170.140.0/28` … `10.170.140.176/28` | `net_lab_core_pers_01*_vnetAddressSpace` |
| Multisession 01a | `10.170.141.0/24` (+ business-unit `/27`s) | `net_lab_core_mult_01a_*` |
| Multisession 01b | `10.170.142.0/24` (+ business-unit subnets) | `net_lab_core_mult_01b_*` |

## Network security groups (`nsg_rules.tf`)

Exact legacy custom rules (Azure defaults 65000+ stay platform-managed). Privileged uses the standard personal Delivery Optimization + deny east-west + deny TURN shape.

## Route tables

- **Personal / Privileged:** `default-to-firewall` (`0.0.0.0/0` → Hub01 Azure Firewall) via `hub01_firewall_private_ip`
- **Multisession:** three-rule dual-hub user-defined routes (`spoke-msh`)
- Legacy privileged local Azure Firewall is **not** redeployed (post–Virtual WAN; Hub01 is the next hop). Firewall CIDR space stays reserved in the VNet address space.

## FSLogix profile storage

- **10 storage accounts** (`fslogix_stas.tf`) — legacy names `uksintvdimultilb{lab}pf{bu}`
- Shares placed per business unit; INT quotas all 100 GB (`fslogix_shares.tf`)
- Deny network rules + Azure Virtual Desktop subnet + optional Agents subnet
- Server Message Block Kerberos / AES-256-GCM / SMB 3.1.1 / multichannel
- Customer-managed keys via per-account user-assigned identity + Multi lab Key Vault (`fslogix_cmk.tf`)

## Lab Key Vaults (`lab_keyvaults.tf`)

15 Premium vaults when privileged is enabled (2 Multi + 12 Personal + 1 Privileged), Deny network access control lists, service-endpoint allow list.

## Personal blob storage (`pers_blob.tf`)

12 × StorageV2 Standard locally redundant storage accounts (`uksintvdipersblb{lab}`).

## Inputs to wire at deploy

- `agents_subnet_id` — management Agents subnet (for storage/Key Vault allow lists)
- `law_id` — Log Analytics workspace for file diagnostics (optional)
- Set `priv_spokes = {}` to skip privileged lab resources

```bash
terraform init -backend=false
terraform validate
```
