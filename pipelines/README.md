# Terraform deploy (Phase H)

Replace legacy Bicep `deploy_build` / `deploy_release` stages with Terraform.
Keep the same AzDo SPNs, service connections, and private agents. Do **not** rewrite GLB libraries.

## Apply order

1. `environments/_global` — shared Virtual WAN  
2. `environments/<env>/connectivity` — Hub01 + Hub02 + baseline FWP (Hub03 spare exists in code only — not deployed)  
3. `environments/<env>/mgmt` — LAW + mgmt spoke + optional RBAC  
4. `environments/<env>/labs` — PERS/MSH spokes + FSLogix storage  
5. `environments/<env>/avd` — host pools, scaling, gallery  

First live bank target: **`int`**. Disconnected sandbox: **`igmf`** (ignitemyfire.co.uk).

## Pipelines in this folder

| File | Role |
|---|---|
| [`templates/terraform-stack.yml`](templates/terraform-stack.yml) | Reusable init / plan / apply (or destroy) job |
| [`tf-release.yml`](tf-release.yml) | Bank release — pick `envName` (`int`/`prd`) + `stackName` |
| [`tf-int-connectivity.yml`](tf-int-connectivity.yml) | Bank convenience wrapper for first cutover stack |
| [`tf-igmf-release.yml`](tf-igmf-release.yml) | **IGMF sandbox** — hardcoded `SC-IGMF-VDI-TF-01` + hosted pool; stacks `_global` \| `connectivity` |
| [`tf-igmf-connectivity.yml`](tf-igmf-connectivity.yml) | IGMF convenience plan→apply for `environments/igmf/connectivity` |

## Service connections / agents

From `docs/subscription-inventory.md` (bank) and IGMF sandbox plan:

| Env | Deploy SC | Agent pool | Variable group |
|---|---|---|---|
| int | `SC-R-VDI-INT-C-01` | `uks-int-vdi-mgmt-vss-01` | `tf-backend-*` (bank) |
| prd | `SC-P-VDI-PRD-C-01` | `uks-prd-vdi-mgmt-vss-01` | `tf-backend-*` (bank) |
| igmf | `SC-IGMF-VDI-TF-01` | `Azure Pipelines` (hosted) | `tf-backend-igmf` |

IGMF state keys: `igmf/_global.tfstate`, `igmf/connectivity.tfstate`. See [`environments/igmf/README.md`](../environments/igmf/README.md).

## Out of scope (unchanged)

- Ops PowerShell / Packer pipelines (TDA name refs only — see `docs/packer-tda-rename-checklist.md`)
- GLB library rewrite, initiatives, Hub02 VPN peer wiring, sub create/destroy
