# Variable set (Phase G)

All deploy-time identity, tagging, DNS, and subscription values live in **tfvars**
(or AzDo variable groups → tfvars), never hardcoded in `.tf` module logic.

Fill before first `plan`/`apply`. Placeholder zeros (`00000000-…`) are intentional.

---

## Tags (`modules/tags` — sole source)

Every Azure resource gets tags **only** from [`modules/tags`](../modules/tags). Stacks call the module and pass `tags = module.tags*.tags`. Resource modules forward that map; they do not invent keys. There is no optional / additional tag channel.

### Bank keys (`mandatory_tags` in tfvars)

Required by `modules/tags`. **Platform standard** for int/prd (all stacks):

| Key | Value |
|---|---|
| `costCentre` | `430034` |
| `securityClassification` | `Limited` |
| `resourceOwner` | `VirtualTeam` |
| `CMDB_AppID` | `AL17611` (legacy platform; confirm per workload if CMDB differs) |

IGMF sandbox uses its own keys (`IGMF-SANDBOX` / `IGMF001` / etc.).

Pass as `var.mandatory_tags` into every env root. Do not embed owner/cost strings in modules.

### Platform keys (module-owned)

Always applied by `modules/tags`:

| Key | Source |
|---|---|
| `environment` | stack `var.environment` |
| `region` | stack `var.location` |
| `workload` | lane → see below |
| `managed-by` | constant `terraform` |
| `repo` | constant `vdi-terraform` |

### Workload lanes

Callers pass a **lane**; the tags module maps to the Azure `workload` string (single place to rename):

| Lane | Tag value | Used by |
|---|---|---|
| `platform` | `vdi-platform` | `config/vwan`, connectivity, mgmt |
| `pers` | `vdi-pers` | labs PERS; avd PERS host pools / workspace / RG |
| `mult` | `vdi-mult` | labs MSH; avd MSH + shared KV / gallery |
| `priv` | `vdi-priv` | labs PRIV; avd PRIV host pools / workspace / RG |

AVD uses three module calls (`tags_mult` / `tags_pers` / `tags_priv`).

---

## Azure identity

| Variable | Where | Notes |
|---|---|---|
| `azure_subscription_id` | every env root | Scope GUID for that stack (connectivity/mgmt/avd/labs/vwan) |
| `azure_tenant_id` | optional env var / tfvars | Prefer `ARM_TENANT_ID` for provider; document AzDo macros below |
| Service connection | AzDo only | `SC-{tier}-VDI-{env}-C-01` — see `docs/subscription-inventory.md` |
| UAA connection | AzDo only | `SC-*-VDI-*-UAA-01` |

AzDo tenant macros (resolve → pipeline vars, not `.tf`):

- `common_dev_tenantId` / `common_bld_tenantId` / `common_prd_tenantId`

Known gallery subscription GUIDs (also in inventory):

| Env | Gallery / AVD-related GUID |
|---|---|
| int | `717872a8-000f-4990-a35b-0f957a9c7856` |
| prod | `a6fe8767-8373-4b41-ad17-b4301ca6fcd0` |
| idv | `358e5bcf-5e4d-47fe-b5b0-ef9f68d02a4f` |

Hub/mgmt/lab GUIDs remain `TODO(deploy)` until pulled from AzDo/GLB.

---

## Corporate DNS

| Variable | Default | Legacy key |
|---|---|---|
| `dns_servers` | `["10.19.96.1", "10.19.97.1"]` | `p_dnsServers` |

Override only if corporate DNS changes. IGMF uses Azure DNS `168.63.129.16`.

---

## Address plan / hubs

See `docs/address-plan-hubs.md`.

| Env | Hub01 | Hub02 | Hub03 |
|---|---|---|---|
| int | `10.170.245.0/24` | `10.170.246.0/24` | — (pending INT Azure 2.0 ranges) |
| prd | `10.218.64.0/22` | `10.218.68.0/22` | `10.218.72.0/22` (**spare in code — not deployed**) |

---

## Per-stack secrets / unique IDs (tfvars)

| Variable | Stack | Notes |
|---|---|---|
| `keyvault_unique_id` | avd | 7-char globally unique KV suffix |
| `gallery_role_assignments` | avd | Packer MSI principal_ids → Contributor |
| `hub01_id` / `hub02_id` | mgmt, labs | From connectivity outputs |
| `hub01_firewall_private_ip` | labs | From connectivity (vWAN AZFW IP, not classic `.4`) |
| `agents_subnet_id` | labs | From mgmt (Deny ACLs) |
| `law_id` | labs (optional), avd | From mgmt |
