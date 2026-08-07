# Terraform deploy (Phase H)

Replace legacy Bicep `deploy_build` / `deploy_release` stages with Terraform.
Keep the same AzDo SPNs, service connections, and private agents. Do **not** rewrite GLB libraries.

## Apply order

1. `_global` — shared Virtual WAN  
2. `connectivity` — Hub01 and/or Hub02 + baseline FWP (Hub03 spare in code only — not deployed)  
3. `mgmt` — LAW + mgmt spoke + optional RBAC  
4. `labs` — PERS/MSH spokes + FSLogix storage  
5. `avd` — host pools, scaling, gallery  

First live bank target: **`int`**. Disconnected sandbox: **`igmf`** (ignitemyfire.co.uk).

## Pipelines in this folder

### Named entry points (prefer these)

| File | Stack | Notes |
|---|---|---|
| [`tf-vWAN-Deployment.yml`](tf-vWAN-Deployment.yml) | `_global` | Virtual WAN |
| [`tf-Hub-Deployment.yml`](tf-Hub-Deployment.yml) | `connectivity` | `hubSelection`: `both` \| `hub01` \| `hub02`; Hub02 includes VPN GW |
| [`tf-Hub-Management-Deployment.yml`](tf-Hub-Management-Deployment.yml) | `mgmt` | LAW, mgmt spoke, alerts |
| [`tf-AVD-Labs-Deployment.yml`](tf-AVD-Labs-Deployment.yml) | `labs` | Lab spokes + storage |
| [`tf-AVD-Hostpool-Deployment.yml`](tf-AVD-Hostpool-Deployment.yml) | `avd` | Host pools, gallery defs |

All support `action`: `plan` \| `apply` \| `destroy`, and `envName`: `int` \| `prd` \| `igmf`.

When **`envName=igmf`**: service connection `SC-IGMF-VDI-TF-01`, hosted pool, variable group `tf-backend-igmf`, and **seed** `*.tfvars.example` → `terraform.tfvars` (including `_global` from `environments/igmf/global.tfvars.example`). Bank envs (`int`/`prd`) never seed.

### Catch-all / convenience

| File | Role |
|---|---|
| [`templates/terraform-stack.yml`](templates/terraform-stack.yml) | Reusable job: scope banner → init / plan / apply (or destroy) |
| [`templates/connectivity-stages.yml`](templates/connectivity-stages.yml) | Hub stage expansion from `hubSelection` |
| [`tf-release.yml`](tf-release.yml) | Catch-all — pick `envName` (`int`/`prd`/`igmf`) + `stackName` (+ `hubSelection` when connectivity) |
| [`tf-int-connectivity.yml`](tf-int-connectivity.yml) | Bank convenience for int connectivity |
| [`tf-igmf-release.yml`](tf-igmf-release.yml) | IGMF sandbox catch-all |
| [`tf-igmf-connectivity.yml`](tf-igmf-connectivity.yml) | IGMF connectivity convenience |

`tf-release.yml` is **not** a prerequisite — it is an alternative to the named pipelines.

### Hub selection (one state file)

State key remains `{env}/connectivity.tfstate`.

| `hubSelection` | Behaviour |
|---|---|
| `hub01` | `enable_hub01=true`, `enable_hub02=false` — FWP + Hub01 secured |
| `hub02` | Both flags `true` — adds/keeps Hub02 **+ VPN gateway**; does not destroy Hub01 |
| `both` | Both flags `true` in one stage (banner lists Hub01 then Hub02) |
| `destroy` | Full connectivity teardown (ignores hubSelection) |

Phased first deploy: run **`hub01`**, then **`hub02`** (or `both`). Narrowing to `hub01` after Hub02 exists **plans destroy of Hub02** — the job logs a warning.

Every run prints a **deployment scope banner** (env, stack, action, state key, component list) and a short plan summary.

## Service connections / agents

From `docs/subscription-inventory.md` (bank) and IGMF sandbox plan:

| Env | Deploy SC | Agent pool | Variable group |
|---|---|---|---|
| int | `SC-R-VDI-INT-C-01` | `uks-int-vdi-mgmt-vss-01` | `tf-backend-*` (bank) |
| prd | `SC-P-VDI-PRD-C-01` | `uks-prd-vdi-mgmt-vss-01` | `tf-backend-*` (bank) |
| igmf | `SC-IGMF-VDI-TF-01` | `Azure Pipelines` (hosted) | `tf-backend-igmf` |

IGMF state keys: `igmf/<stack>.tfstate` (`_global`, `connectivity`, `mgmt`, `labs`, `avd`). See [`environments/igmf/README.md`](../environments/igmf/README.md).

## Out of scope (unchanged)

- Ops PowerShell / Packer pipelines (TDA name refs only — see `docs/packer-tda-rename-checklist.md`)
- GLB library rewrite, initiatives, Hub02 VPN **site/peer** wiring, sub create/destroy
