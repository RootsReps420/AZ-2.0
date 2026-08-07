# Subscription inventory (Phase B)

Captured from legacy `params/{env}/config.yml` and related files.  
**Subscription GUIDs for hub/mgmt/avd/lab are not all present in config.yml** — they live in AzDo/GLB variable groups. Fill `TODO(deploy)` cells before apply.

Env codes: keep `idv`/`ici`/`itt`/`int` split; `prd` → Terraform env `prod`; **drop `ppd`**.

---

## Environment → service connections

| Env | Legacy code | TF env | Sub name prefix | Deploy SPN | UAA SPN | Gallery subscription ID |
|---|---|---|---|---|---|---|
| Dev-tier | `idv` | `idv` | `idv-vdi` | `SC-T-VDI-IDV-C-01` | `SC-T-VDI-UAA-01` | `358e5bcf-5e4d-47fe-b5b0-ef9f68d02a4f` |
| Dev-tier | `ici` | `ici` | `ici-vdi` | `SC-T-VDI-ICI-C-01` | `SC-T-VDI-UAA-01` | TODO(deploy) |
| Dev-tier | `itt` | `itt` | `itt-vdi` | `SC-T-VDI-ITT-C-01` | `SC-T-VDI-UAA-01` | TODO(deploy) |
| DT (dev test) | `int` | `int` | `int-vdi` | `SC-R-VDI-INT-C-01` | `SC-R-VDI-ALL-UAA-01` | `717872a8-000f-4990-a35b-0f957a9c7856` |
| Production | `prd` | `prod` | `prd-vdi` | `SC-P-VDI-PRD-C-01` | `SC-P-VDI-ALL-UAA-01` | `a6fe8767-8373-4b41-ad17-b4301ca6fcd0` |

App registration / object IDs (from config.yml):

| Env | App ID | Object ID |
|---|---|---|
| idv | `d6889322-8e7e-40fb-84ec-0eaf996d8e10` | `5d704541-4f6d-4888-9a92-c2bb7e8fa4f3` |
| ici | `02c6716f-107b-493b-8105-823d5a27c5cc` | `33302985-64b9-4d54-b24b-22f8d0f302ef` |
| itt | `bd42a599-e458-4ce0-bcc2-148ed3d5ff5a` | `5ac3fb22-2ae6-4645-8344-48f0a9f4eabc` |
| int | `fc9d5727-3be0-4411-9493-e0a08652d946` | `8b14ddaa-bf5c-4f3f-bfdd-38df5329907d` |
| prd | `ddeac00d-897a-4fcc-b8e4-6155a009d22d` | `9efaa678-fe19-4045-bdb8-d4ad2042e0a4` |

Tenant IDs: referenced as AzDo macros (`common_dev_tenantId` / `common_bld_tenantId` / `common_prd_tenantId`) — resolve from AzDo and put in tfvars (not `.tf`).

---

## Per-scope Azure subscriptions (fill GUIDs)

| Scope | Purpose | INT GUID | PROD GUID |
|---|---|---|---|
| connectivity / hub | vWAN hubs, FW, VPN, ER GW | TODO(deploy) | TODO(deploy) |
| mgmt | LAW, mgmt VNet, agents | TODO(deploy) | TODO(deploy) |
| avd | Host pools, workspaces, KV, gallery RG | Known gallery GUID usable as start: `717872a8-000f-4990-a35b-0f957a9c7856` — confirm AVD sub | Known gallery: `a6fe8767-8373-4b41-ad17-b4301ca6fcd0` — confirm AVD sub |
| lab (pers/mult/priv) | Spoke VNets, session hosts, FSLogix | TODO(deploy) per lab | TODO(deploy) per lab |
| image-build | Packer build sub | TODO(deploy) | TODO(deploy) |
| `vwan` | Shared Virtual WAN | TODO(deploy) — often same as connectivity | TODO(deploy) |

Private agents: `uks-{env}-vdi-mgmt-vss-01` (PS-managed).

---

## Bank tags (from legacy subscription tags)

From `common_subscriptionTags` (int/prd):

| Key | Example value |
|---|---|
| `CMDB_AppID` | `AL17611` |
| `securityClassification` | `Limited` |
| `costCentre` | `CLL411S1XJ` |
| `resourceOwner` | Fletcher, Wayne (Colleague ID 0028929) |

These map to `modules/tags` mandatory keys (Phase A).

---

## Dev-tier purpose notes

| Code | Known purpose |
|---|---|
| `int` | **DT (dev test)** — first live TF target |
| `idv` | TBD — document when confirmed |
| `ici` | TBD — nightly destroy exists in platform mgmt pipeline |
| `itt` | TBD |

Do not consolidate; start TF with `int` + `prod` only.
