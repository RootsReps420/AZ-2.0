# environments/igmf

Disconnected **ignitemyfire.co.uk** sandbox for smoke-test build/destroy.
Not bank cutover (`int`/`prd`). Multi-region work is on hold — use this path to
validate vWAN + hubs freely.

## Pipelines (IGMF AzDo only)

| File | Role |
|---|---|
| [`pipelines/tf-igmf-release.yml`](../../pipelines/tf-igmf-release.yml) | Parameterised: `_global` \| `connectivity` + plan/apply/destroy |
| [`pipelines/tf-igmf-connectivity.yml`](../../pipelines/tf-igmf-connectivity.yml) | Convenience plan→apply connectivity |

Hardcoded in those YAMLs:

| Param | Value |
|---|---|
| Service connection | `SC-IGMF-VDI-TF-01` |
| Agent pool | `Azure Pipelines` (Microsoft-hosted) |
| Variable group | `tf-backend-igmf` |
| State key prefix | `igmf/<stack>.tfstate` |

Bank `tf-release.yml` is unchanged (still `SC-R-VDI-*` / private pools).

## Apply order

```text
1. environments/_global          (state: igmf/_global.tfstate)
2. environments/igmf/connectivity
```

Wire `_global` output `vwan_id` into connectivity `terraform.tfvars` before applying hubs.

## Stacks

| Stack | Status |
|---|---|
| connectivity | Present — Hub01 + Hub02 + stub FWP |
| mgmt / labs / avd | Not yet — copy from `environments/int/*` in later sandbox phases |

## Bank landmines (do not bring into IGMF)

| Bank default | IGMF action |
|---|---|
| DNS `10.19.96.1` / `10.19.97.1` | `168.63.129.16` (Azure DNS) |
| Bank SPNs / private agents | Use `SC-IGMF-VDI-TF-01` + hosted pool |
| Bank mandatory tag values | Use sandbox placeholders (four keys still required) |
| ER / Palo Alto | Leave unset |

## Offline check

```bash
cd environments/igmf/connectivity
terraform init -backend=false
terraform validate
```
