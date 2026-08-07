# environments/igmf

Disconnected **ignitemyfire.co.uk** sandbox — full peer of `int`/`prd`
(connectivity + mgmt + labs + avd). Not bank cutover.

## Version control

| Remote | Role |
|---|---|
| GitHub `origin` (`main`) | Private source of truth |
| AzDo repo **Azure-2.0** (`igmf` remote, `main`) | What pipeline **Azure-2.0** reads |

No GitHub service connection on the shared AzDo org. After every change you want to run:

```powershell
git push origin main
git push igmf main
```

## Pipelines

Prefer the **named** entry points with `envName=igmf` (same as bank):

| File | Stack |
|---|---|
| [`tf-vWAN-Deployment.yml`](../../pipelines/tf-vWAN-Deployment.yml) | vwan → `config/vwan` |
| [`tf-Hub-Deployment.yml`](../../pipelines/tf-Hub-Deployment.yml) | connectivity |
| [`tf-Hub-Management-Deployment.yml`](../../pipelines/tf-Hub-Management-Deployment.yml) | mgmt |
| [`tf-AVD-Labs-Deployment.yml`](../../pipelines/tf-AVD-Labs-Deployment.yml) | labs |
| [`tf-AVD-Hostpool-Deployment.yml`](../../pipelines/tf-AVD-Hostpool-Deployment.yml) | avd |

Convenience alternatives: [`tf-igmf-release.yml`](../../pipelines/tf-igmf-release.yml), [`tf-igmf-connectivity.yml`](../../pipelines/tf-igmf-connectivity.yml).

| Param | uksouth value |
|---|---|
| Service connection | `SC-IGMF-VDI-TF-01` |
| Agent pool | `Azure Pipelines` (Microsoft-hosted) |
| Variable group | `tf-backend-igmf` |
| State key | `igmf/<stack>.tfstate` |

**Values:** connectivity uses [`environments/region/uksouth/igmf.connectivity.tfvars`](../region/uksouth/igmf.connectivity.tfvars) (`-var-file`; seeding skipped). Other stacks still seed from `*.tfvars.example` (vwan from [`global.tfvars.example`](global.tfvars.example)) until region files exist.

Full LLD: [../../README.md](../../README.md).

## Apply order / phases

```text
1. vwan            (done)  → save vwan_id
2. connectivity       (done)  → save hub01_id, hub02_id, hub01_firewall_private_ip
3. mgmt               (next)  → save law_id, agents_subnet_id
4. labs               (thin)  → spokes; FSLogix/blob off in example
5. avd                (optional / heavy)
6. destroy            reverse: avd → labs → mgmt → connectivity → vwan
```

### What needs to go where

| From | Output | Paste into | Variable |
|---|---|---|---|
| `vwan` | `vwan_id` | `region/<loc>/igmf.connectivity.tfvars` (already set for uksouth) | `virtual_wan_id` |
| connectivity | `hub01_id` | mgmt + labs examples (or future region tfvars) | `hub01_id` |
| connectivity | `hub01_firewall_private_ip` | mgmt + labs examples | `hub01_firewall_private_ip` |
| connectivity | `hub02_id` | labs example | `hub02_id` |
| mgmt | `law_id` | labs + avd examples (optional) | `law_id` |
| mgmt | `agents_subnet_id` | labs example | `agents_subnet_id` |

Subscription (all stacks): `cc1ccb8d-18a1-4dca-aa5a-54607876c990`.

### Phase 3 — mgmt (next concrete steps)

1. Edit [`mgmt/terraform.tfvars.example`](mgmt/terraform.tfvars.example) — paste connectivity `hub01_*`; keep `devops_vm_contributor_principal_id = null` and Azure DNS
2. Dual-push `main`
3. AzDo **Azure-2.0** → stack **`mgmt`** → **plan** → **apply**
4. Save `law_id` / `agents_subnet_id` for labs/avd

### Phase 4 — labs

1. Edit [`labs/terraform.tfvars.example`](labs/terraform.tfvars.example) — paste hub01/hub02/firewall IP
2. Keep `enable_fslogix = false` / `enable_pers_blob = false`; set `enable_lab_keyvaults = false` for spokes-only
3. Dual-push → stack **`labs`** → plan → apply

### Phase 5 — avd (skip unless needed)

Still deploys 30 MSH pools + gallery. Prefer `enable_pers_host_pools = false` / `enable_priv_host_pools = false` for a lighter smoke; leave Packer/WVD unset.

## Stacks

| Stack | Status |
|---|---|
| connectivity | Hub01 + Hub02 + stub FWP (Azure DNS) — applied |
| mgmt | LAW + AgentsSubnet; bank devops SP default forced to `null` |
| labs | Full spoke code; thin flags in example |
| avd | Full catalogs; optional |

`vwan` is shared under `config/vwan`; IGMF seeds from
[`global.tfvars.example`](global.tfvars.example) (state `igmf/vwan.tfstate`).

## Bank landmines (do not bring into IGMF)

| Bank default | IGMF action |
|---|---|
| DNS `10.19.96.1` / `10.19.97.1` | `168.63.129.16` (Azure DNS) |
| Bank SPNs / private agents | `SC-IGMF-VDI-TF-01` + hosted pool |
| Bank devops VM Contributor SP | `devops_vm_contributor_principal_id = null` |
| Bank mandatory tag values | Sandbox placeholders (four keys still required) |
| ER / Palo Alto | Leave unset |
| GitHub SC into shared AzDo | Do not — dual-push only |

## Offline check

```bash
cd environments/igmf/connectivity   # or mgmt / labs / avd
terraform init -backend=false
terraform validate
```
