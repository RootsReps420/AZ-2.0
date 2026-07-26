# VDI Terraform (AzTF_vWAN)

Terraform monorepo for an **Azure Virtual WAN** platform that hosts **Azure Virtual Desktop** (personal, privileged, and multisession) for the bank VDI estate.

This replaces the legacy Azure 1.0 Bicep deploy path for **platform infrastructure and AVD service objects**. Session-host VMs, Packer image **versions**, agent VMSS, and day-2 ops stay in existing PowerShell / AzDo pipelines.

## What it deploys

| Layer | Owns |
|---|---|
| **Connectivity** | Shared Virtual WAN, Hub01 (secured: AZFW + ExpressRoute + Routing Intent), Hub02 (VPN gateway shell) |
| **Management** | Log Analytics, alerts, action group, mgmt AgentsSubnet spoke |
| **Labs** | PERS / PRIV / MSH spoke VNets, FSLogix storage, lab Key Vaults, PERS blobs |
| **AVD** | Host pools, workspaces, scaling plans, compute gallery + image **definitions**, MSH DCRs |

**Hard split:** Terraform builds the estate; PowerShell places users and VMs into it.

## Topology (one glance)

```text
Virtual WAN (_global)
   ├─ Hub01 secured  →  mgmt + PERS + PRIV   (firewall / Routing Intent / ER)
   └─ Hub02 unsecured → MSH also attaches    (internet via VPN/Proxy path; RFC1918 → Hub01 FW)
```

Environments in scope: **`int`** (DT) and **`prd`**. Region today: **uksouth**.

## Apply order

```text
environments/_global
  → environments/<env>/connectivity
  → environments/<env>/mgmt
  → environments/<env>/labs
  → environments/<env>/avd
```

`<env>` = `int` | `prd`. One AzDo run per stack (`pipelines/tf-release.yml`). Wire stack outputs into the next stack’s `terraform.tfvars` (no remote-state data sources yet).

## Repo map

| Path | Role |
|---|---|
| [`modules/`](modules/) | Reusable bricks (naming, tags, platform, core, avd, gallery) |
| [`environments/_global`](environments/_global/) | Shared Virtual WAN |
| [`environments/int/*`](environments/int/) | First live target (DT) |
| [`environments/prd/*`](environments/prd/) | Production mirrors |
| [`pipelines/`](pipelines/) | AzDo Terraform init / plan / apply |
| [`docs/dummies-guide.md`](docs/dummies-guide.md) | **Start here** — as-built LLD (diagrams, modules, DevOps vs legacy scripts, CIDRs, AVD, wiring) |

## Who does what

| Terraform (this repo) | Still PowerShell / Packer |
|---|---|
| Hubs, spokes, UDRs, NSGs | Session-host VMs |
| LAW, alerts, FSLogix STAs, lab KVs | Token consume, placement, decom, power |
| Host pools, workspaces, scaling plans | Desktop Virtualization User / AAD group assign |
| Gallery + image **definitions** | Packer image **versions** |
| MSH DCR *resources* | DCR associations onto VMs; agent VMSS |

Deploy SPNs / private agents are unchanged from legacy (`SC-R-VDI-INT-C-01` / `SC-P-VDI-PRD-C-01` on `uks-{env}-vdi-mgmt-vss-01`).

## Docs

| Doc | Purpose |
|---|---|
| [`docs/dummies-guide.md`](docs/dummies-guide.md) | As-built low-level design |
| [`docs/plans/`](docs/plans/README.md) | Build + migration plans (01–04; gap analysis complete) |
| [`docs/variable-set.md`](docs/variable-set.md) | Tags / DNS / identity checklist for tfvars |
| [`docs/address-plan-hubs.md`](docs/address-plan-hubs.md) | Hub/spoke CIDR decisions |
| [`docs/subscription-inventory.md`](docs/subscription-inventory.md) | SPNs, app IDs, known gallery GUIDs |

Offline until creds: `terraform init -backend=false` + `terraform validate` per stack.
