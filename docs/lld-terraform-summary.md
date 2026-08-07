# Terraform LLD — summary (source extract)

**Source document:** `C:\Users\Dan\Documents\terraform low level design .docx`  
**Status:** DRAFT · **Date:** 2026-07-15 · **Audience:** Engineering Team, Product Owner  
**Confluence:** VDI Platform / Engineering

This file is an in-repo summary so the dummy’s guide can cite the LLD without relying on the Word path. Prefer the Word doc if wording differs.

---

## What the LLD says this repo is for

The LLD is the **code delivery spec** for the AVD Platform Modernisation programme. It describes how Terraform should implement the **Azure 2.0** VDI architecture — it does **not** re-explain the full Azure 2.0 design.

### Two hard decisions (LLD §2)

1. **Session host VMs are not managed by Terraform.** Hosts stay on existing `vdi-mult` / `vdi-scripts` Azure DevOps pipelines. Terraform builds the platform the hosts run on.
2. **Azure Policy is out of scope.** Central Public Cloud owns policy.

### Network shape (LLD §2)

| Hub | Role | Used by |
|---|---|---|
| **Hub01 — Secured** | Azure Firewall + Routing Intent + ExpressRoute | PERS (personal desktops) |
| **Hub02 — Unsecured** | VPN Gateway (internet via Palo Alto Proxy) | MSH (multi-session hosts) |
| **Hub03 — Spare** (Azure 2.0 addendum) | Bare virtual hub blueprint (no FW/VPN/ER/spokes) | **Config only** — CIDR reserved; module not wired in env roots until uncommented |

Shared **Azure Virtual WAN**. Regions in the LLD vision: **UK South**, **Italy North**, **Spain Central**.

---

## How the LLD said the repo should look (§3)

```
vdi-terraform/
├── modules/          # all logic (building blocks)
│   ├── naming/
│   ├── tags/
│   ├── platform/     # vWAN, hubs, firewall, monitoring
│   ├── core/         # spokes, Key Vault, FSLogix
│   ├── avd/          # host pools, workspaces, scaling
│   └── gallery/
├── config/           # shared platform config (not an env)
│   └── vwan/         # Virtual WAN (once)
├── environments/     # env-scoped config — call modules
│   ├── int|prd|igmf/{connectivity,mgmt,labs,avd}/
│   └── region/{uksouth,italynorth,spaincentral}/
├── docs/
├── pipelines/
├── scripts/
└── tests/
```

**Rule:** modules hold logic; environments hold variable values + module calls.

> **Later change (migration plan 02):** for the Azure 1.0 cutover, live targets are `environments/{int,prd}/{connectivity,mgmt,labs,avd}` plus `environments/region/<location>/…` values. The LLD’s old `uksouth/{dev,prod}` mega-roots were removed. See [../README.md](../README.md).

---

## Module catalogue (LLD §4) — purpose in one line

| Module | LLD purpose |
|---|---|
| `naming` | TDA bank names — never hand-type resource names |
| `tags` | Mandatory bank tags + auto tags (`managed-by`, `repo`, …) |
| `platform/vwan` | Global Virtual WAN |
| `platform/hub-secured` | Hub01 + AZFW + ER GW + Routing Intent |
| `platform/hub-unsecured` | Hub02 + VPN gateway |
| `platform/hub-spare` | Hub03 spare bare hub blueprint (not env-wired today; uncomment to deploy) |
| `platform/firewall-policy` | Firewall rules live here, not on the firewall resource |
| `platform/management` | LAW / DCR / alerts / workbooks |
| `core/spoke-pers` | PERS spoke → Hub01 only; no UDR (Routing Intent) |
| `core/spoke-msh` | MSH spoke → Hub01 + Hub02; three-rule UDR |
| `core/keyvault` | Per-lab Key Vault |
| `core/storage-fslogix` | FSLogix storage account + shares |
| `avd/hostpool` | Host pool + **registration token** for PS pipelines |
| `avd/workspace` | Workspace + application groups |
| `avd/scalingplan` | Scaling plans (LLD focused on personal; code also does pooled MSH) |
| `gallery/*` | Compute Gallery + image definitions (Packer publishes versions) |

### MSH UDR (LLD §4.3)

1. `0.0.0.0/0` → Hub02 VPN (internet / Palo Alto)  
2. Service tags → Hub01 firewall private IP  
3. RFC1918 → Hub01 firewall private IP  

---

## LLD open items (§8) — short status vs this repo

| # | Item | Status in this repo (2026-07) |
|---|---|---|
| 1 | `itn` / `spc` region codes | Still pending TDA — Italy/Spain env roots not cutover targets yet |
| 2 | AVD abbrs `vdhp/vdws/vdag/vdsp` | **Diverged** — naming uses `vdh/vdw/vda/vds` |
| 3 | Mandatory bank tag keys | **Resolved** — `costCentre`, `securityClassification`, `resourceOwner`, `CMDB_AppID` |
| 4–12 | HCP Terraform / Backstage / OIDC / Variable Sets | Mostly **deferred** — AzDo TF pipelines scaffolded; TFC not required for current scaffold |
| 5 | Palo Alto VPN endpoint for Hub02 | **Still open** — VPN GW scaffold only; peer/site/connection not invent |

---

## CI/CD the LLD wanted (§9)

- Azure DevOps for quality gates (no GitHub Actions).
- Terraform Cloud (HCP) for plan/apply with path-based workspaces.
- Quality gate: fmt, validate, tflint, Checkov, commitlint.
- Drift: TFC Health Assessments **or** scheduled AzDo speculative plans.

**Today:** AzDo Terraform apply templates under `pipelines/` keep existing SPNs/agents; full TFC model remains an LLD open track.

---

## Delivery phases (LLD §7) — idea

1. Repo + naming/tags + TFC scaffolding  
2. vWAN + hubs + FWP + management (UK South)  
3. Spokes + KV + FSLogix (needs Hub02 VPN — Open Item 5)  
4. AVD objects  
5. Gallery  
6. Promote to prod / MSH cutover  
7. Decommission classic hub  
8. Italy North + Spain Central  

Migration plan 02 folded Azure 1.0 IPs, multi-sub split, and MSH scaling catalog into the same modules while keeping these LLD decisions.
