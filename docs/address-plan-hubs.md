# Address plan notes (connectivity hubs)

Cross-checked against `legacy/platform/vdi-platform/params/{int,prd,ppd}/config.yml`,
`legacy/pers/vdi-core-pers/params/{int,prd}/config.yml`, and the Azure 2.0 hub IP
CIDR ranges document (Production `10.218.64.0/20`).

Hub prefixes must be **unique across environments** when they share the `_global`
Virtual WAN (int + prd attach to the same `virtual_wan_id`).

Classic hub VNet slices (`AzureFirewallSubnet`, `AzureFirewallManagementSubnet`,
`GatewaySubnet`) are **not** modelled under vWAN — AZFW / ER / VPN are hub SKUs.

DNS (both envs): `10.19.96.1`, `10.19.97.1` (`p_dnsServers`) — **Used**.

---

## INT (Azure 1.0 / current TF defaults — pending Azure 2.0 INT ranges)

| Hub | CIDR | Status |
|---|---|---|
| Hub01 (secured) | `10.170.245.0/24` | **Used** — legacy `net_hub_01_vnetAddressSpace` |
| Hub02 (unsecured) | `10.170.246.0/24` | **Used** — accepted TF default (ex-PPD Hub01; within int `net_superNetCidr` `10.170.128.0/17`) |
| Hub03 | — | Not in int until INT Azure 2.0 ranges arrive |

---

## PRD (Azure 2.0 — Production)

Parent block: **`10.218.64.0/20`** (`10.218.64.1`–`10.218.75.254`) as three `/22` hubs.
Microsoft: hub min `/24`, recommend `/23+`; **Azure Firewall in hub requires `/22`** for max scale.

| Hub | Role | CIDR | Notes |
|---|---|---|---|
| Hub01 | Secured (AZFW + Routing Intent + ER) | `10.218.64.0/22` | Production hub 1 |
| Hub02 | Unsecured (VPN GW shell / MSH path) | `10.218.68.0/22` | Production hub 2 |
| Hub03 | Spare bare (reserved) | `10.218.72.0/22` | **Not deployed** — CIDR + `hub-spare` module kept in code; `module "hub_spare"` commented out in `prd/connectivity`. Uncomment when a region needs it (region-agnostic). Doc typo `0.218.72.0/22` treated as `10.218.72.0/22`. |

### Superseded Azure 1.0 / interim prd defaults

| Former | CIDR | Status |
|---|---|---|
| Classic Hub01 | `10.170.247.0/24` | Superseded by `10.218.64.0/22` |
| Interim Hub02 | `10.170.244.0/24` | Superseded by `10.218.68.0/22` |

### Rejected / do not use

| CIDR | Why |
|---|---|
| `10.170.248.0/24` as any hub | **Collides** with prod `net_lab_core_pers_01l` = `10.170.248.0/21` |
| `10.170.246.0/24` for **both** int and prod Hub02 | Breaks cross-env uniqueness on shared vWAN |
| Reusing int `10.170.245.0/24` as a prd hub | Is live INT Hub01 |

### Spoke non-overlap (prd)

MSH `10.218.16.0/21` + `10.218.24.0/21` do **not** overlap hub parent `10.218.64.0/20`.

---

## Verified spokes (selected — unchanged by hub renumber)

| Env | Resource | CIDR | Source |
|---|---|---|---|
| int | mgmt | `10.170.139.192/26` | `net_mgmt_*` |
| int | PERS 01a–01l | `10.170.140.{0,16,…,176}/28` | pers `config.yml` |
| int | MSH 01a / 01b | `10.170.141.0/24`, `10.170.142.0/24` + named `/27`–`/25` subnets | pers `config.yml` |
| prod | mgmt | `10.170.241.64/26` | `net_mgmt_*` |
| prod | PERS 01a–01l | `/21`/`/22`/`/27` map from platform `prd/config.yml` | verified |
| prod | MSH 01a / 01b | `10.218.16.0/21`, `10.218.24.0/21` + named subnets | pers `prd/config.yml` |

## Classic → vWAN mapping

Under Azure Virtual WAN, Hub01 is a **virtual hub** with `address_prefix` = the hub CIDR
(now Azure 2.0 `/22` for prd). Firewall and ER/VPN gateways attach as hub SKUs —
not as classic VNet subnets inside the prefix.
