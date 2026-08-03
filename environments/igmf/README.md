# environments/igmf

Disconnected **ignitemyfire.co.uk** sandbox — full peer of `int`/`prd`
(connectivity + mgmt + labs + avd). Not bank cutover. Multi-region work is on
hold — use this path to validate vWAN + hubs + platform stacks freely.

## Pipelines (IGMF AzDo only)

| File | Role |
|---|---|
| [`pipelines/tf-igmf-release.yml`](../../pipelines/tf-igmf-release.yml) | Parameterised: `_global` \| `connectivity` \| `mgmt` \| `labs` \| `avd` + plan/apply/destroy |
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
1. environments/_global               (state: igmf/_global.tfstate)
2. environments/igmf/connectivity     → save hub01_id, hub02_id, hub01_firewall_private_ip
3. environments/igmf/mgmt             → save law_id, agents_subnet_id
4. environments/igmf/labs             → spokes (+ optional FSLogix/KV/blob)
5. environments/igmf/avd              → host pools + gallery
```

Wire outputs into the next stack’s `terraform.tfvars` (or update the committed
`*.tfvars.example` before a `seedIgmfTfvars` run). Destroy reverse order.

## Stacks

| Stack | Status |
|---|---|
| connectivity | Hub01 + Hub02 + stub FWP (Azure DNS) |
| mgmt | LAW + AgentsSubnet; `devops_vm_contributor_principal_id = null` |
| labs | Full spoke code; example turns off FSLogix + PERS blobs |
| avd | Full catalogs; Packer/WVD principals left unset |

`_global` is shared code under `environments/_global`; IGMF seeds it from
[`global.tfvars.example`](global.tfvars.example) (state key `igmf/_global.tfstate`).

## Bank landmines (do not bring into IGMF)

| Bank default | IGMF action |
|---|---|
| DNS `10.19.96.1` / `10.19.97.1` | `168.63.129.16` (Azure DNS) |
| Bank SPNs / private agents | Use `SC-IGMF-VDI-TF-01` + hosted pool |
| Bank devops VM Contributor SP | `devops_vm_contributor_principal_id = null` |
| Bank mandatory tag values | Use sandbox placeholders (four keys still required) |
| ER / Palo Alto | Leave unset |

## Offline check

```bash
cd environments/igmf/connectivity   # or mgmt / labs / avd
terraform init -backend=false
terraform validate
```
