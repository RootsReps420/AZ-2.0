# environments/prd/labs

PERS + MSH spokes for **prd**. Session hosts stay PowerShell.

## Verified PRD CIDRs (legacy `config.yml`)

| Spoke | CIDR | Source |
|---|---|---|
| PERS 01a–01h, 01k | `/21` from `10.170.160.0` … `10.170.232.0` | platform `prd/config.yml` |
| PERS 01i | `10.170.224.0/22` | Robotics |
| PERS 01j | `10.170.241.0/27` | P&D (adjacent to mgmt `241.64/26`) |
| PERS 01l | `10.170.248.0/21` | **blocks** Hub02 using `248/24` |
| MSH 01a | `10.218.16.0/21` (+ named `/24`/`/26`s) | pers `prd/config.yml` |
| MSH 01b | `10.218.24.0/21` (+ named subnets) | pers `prd/config.yml` |

## NSGs (`nsg_rules.tf`)

Exact legacy custom rules (Azure defaults 65000+ stay platform-managed):

| Lab type | Scope | Pattern |
|---|---|---|
| PERS most (01a–h, 01j) | AVDSubnet | DO TCP+UDP, deny east-west, deny TURN |
| PERS 01i | AVDSubnet | DO TCP+UDP + RPA allow + deny east-west (no TURN) |
| PERS 01k/01l | AVDSubnet | Combined TCP DO + deny east-west |
| MSH 01a/01b | **VNet** CIDR | Same 4-rule set on every AVDSubnet NSG |

## Route tables

- **PERS:** legacy `default-to-firewall` (`0.0.0.0/0` ? Hub01 AZFW, BGP prop off) via `hub01_firewall_private_ip`
- **MSH:** three-rule dual-hub UDR (existing `spoke-msh`)

## FSLogix (`fslogix_shares.tf`)

PRD mirrors legacy hostpool JSON quotas (`profiles-{bu}-{pool}`) + `redirection` **100 GB**. Includes `profiles-005-01` = **51200** GB.

```bash
terraform init -backend=false
terraform validate
```
