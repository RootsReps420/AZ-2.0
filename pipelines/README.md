# Terraform deploy (Phase H)

Replace legacy Bicep `deploy_build` / `deploy_release` stages with Terraform.
Keep the same AzDo SPNs, service connections, and private agents. Do **not** rewrite GLB libraries.

## Apply order

1. `environments/_global` — shared Virtual WAN  
2. `environments/<env>/connectivity` — Hub01 + Hub02 + baseline FWP (+ Hub03 spare on **prd**)  
3. `environments/<env>/mgmt` — LAW + mgmt spoke + optional RBAC  
4. `environments/<env>/labs` — PERS/MSH spokes + FSLogix storage  
5. `environments/<env>/avd` — host pools, scaling, gallery  

First live target: **`int`**.

## Pipelines in this folder

| File | Role |
|---|---|
| [`templates/terraform-stack.yml`](templates/terraform-stack.yml) | Reusable init / plan / apply (or destroy) job |
| [`tf-release.yml`](tf-release.yml) | Parameterised release — pick `envName` + `stackName` |
| [`tf-int-connectivity.yml`](tf-int-connectivity.yml) | Convenience wrapper for first cutover stack |

## Service connections / agents

From `docs/subscription-inventory.md`:

| Env | Deploy SPN | Agent pool (example) |
|---|---|---|
| int | `SC-R-VDI-INT-C-01` | `uks-int-vdi-mgmt-vss-01` |
| prd | `SC-P-VDI-PRD-C-01` | `uks-prd-vdi-mgmt-vss-01` |

Wire real pool names / backend config in AzDo variable groups (`tf-backend-*`).

## Out of scope (unchanged)

- Ops PowerShell / Packer pipelines (TDA name refs only — see `docs/packer-tda-rename-checklist.md`)
- GLB library rewrite, initiatives, Hub02 VPN peer wiring, sub create/destroy
