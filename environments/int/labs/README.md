# environments/int/labs

PERS + MSH spokes for **int**. Session hosts stay PowerShell.

## Verified INT CIDRs (legacy `config.yml`)

| Spoke | CIDR | Source |
|---|---|---|
| PERS 01a–01l | `10.170.140.0/28` … `10.170.140.176/28` | `net_lab_core_pers_01*_vnetAddressSpace` |
| MSH 01a | `10.170.141.0/24` (+ BU `/27`s) | `net_lab_core_mult_01a_*` |
| MSH 01b | `10.170.142.0/24` (+ BU subnets) | `net_lab_core_mult_01b_*` |

## NSGs (`nsg_rules.tf`)

Exact legacy custom rules (Azure defaults 65000+ stay platform-managed):

| Lab type | Scope | Pattern |
|---|---|---|
| PERS most (01a–h, 01j) | AVDSubnet | DO TCP+UDP, deny east-west, deny TURN |
| PERS 01i | AVDSubnet | DO TCP+UDP + RPA allow + deny east-west (no TURN) |
| PERS 01k/01l | AVDSubnet | Combined TCP DO + deny east-west |
| MSH 01a/01b | **VNet** CIDR | Same 4-rule set on every AVDSubnet NSG |

## Route tables

- **PERS:** legacy `default-to-firewall` (`0.0.0.0/0` → Hub01 AZFW, BGP prop off) via `hub01_firewall_private_ip`
- **MSH:** three-rule dual-hub UDR (existing `spoke-msh`)

## FSLogix (`fslogix_shares.tf`)

INT RTL: `profiles-{bu}-{pool}` all **100 GB** + `redirection` **100 GB** (not PRD multi-TB quotas).

```bash
terraform init -backend=false
terraform validate
```
