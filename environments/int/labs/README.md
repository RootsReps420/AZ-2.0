# environments/int/labs

Personal and multisession lab spokes for **int**. Session hosts stay PowerShell.

## Verified INT CIDRs (legacy `config.yml`)

| Spoke | CIDR | Source |
|---|---|---|
| Personal 01a–01l | `10.170.140.0/28` … `10.170.140.176/28` | `net_lab_core_pers_01*_vnetAddressSpace` |
| Multisession 01a | `10.170.141.0/24` (+ business-unit `/27`s) | `net_lab_core_mult_01a_*` |
| Multisession 01b | `10.170.142.0/24` (+ business-unit subnets) | `net_lab_core_mult_01b_*` |

## Network security groups (`nsg_rules.tf`)

Exact legacy custom rules (Azure defaults 65000+ stay platform-managed).

## Route tables

- **Personal:** `default-to-firewall` (`0.0.0.0/0` → Hub01 Azure Firewall) via `hub01_firewall_private_ip`
- **Multisession:** three-rule dual-hub user-defined routes (`spoke-msh`)

## FSLogix profile storage

- **10 storage accounts** (`fslogix_stas.tf`) — legacy names `uksintvdimultilb{lab}pf{bu}`
- Shares placed per business unit; INT quotas all 100 GB (`fslogix_shares.tf`)
- Deny network rules + Azure Virtual Desktop subnet + optional Agents subnet
- Server Message Block Kerberos / AES-256-GCM / SMB 3.1.1 / multichannel
- Customer-managed keys via per-account user-assigned identity + Multi lab Key Vault (`fslogix_cmk.tf`)

## Lab Key Vaults (`lab_keyvaults.tf`)

14 Premium vaults (2 Multi + 12 Personal), Deny network access control lists, service-endpoint allow list.

## Personal blob storage (`pers_blob.tf`)

12 × StorageV2 Standard locally redundant storage accounts (`uksintvdipersblb{lab}`).

## Inputs to wire at deploy

- `agents_subnet_id` — management Agents subnet (for storage/Key Vault allow lists)
- `law_id` — Log Analytics workspace for file diagnostics (optional)

```bash
terraform init -backend=false
terraform validate
```
