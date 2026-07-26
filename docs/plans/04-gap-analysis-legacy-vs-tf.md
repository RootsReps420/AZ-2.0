# Gap analysis — legacy Azure 1.0 vs Terraform

**Status:** In progress — Waves A/B done; Wave C started (Log Analytics, data collection, alerts shell, RBAC hooks); alert rule templates + personal host pools still open.  
**Date:** 2026-07-26  
**Scope:** TF-worthy deployables in legacy vs `environments/{int,prd}` + `modules/**`.

**Companion:** [03-cursor-handoff.md](03-cursor-handoff.md) · [02-azure-1.0-to-terraform-migration.md](02-azure-1.0-to-terraform-migration.md)  
**Working plan:** Cursor `exact_legacy_tf_parity_22b2ce4a` (supersedes first-pass gap-audit plan).

---

## Scope

**Compared:** legacy `platform` / `pers` / `mult` / `scripts` / `images` deployables vs current Terraform cutover stacks.

**Excluded (by design):**

- Session-host VMs / extensions / placement
- Classic hub/spoke → vWAN topology rewrite (already done)
- Packer image **versions**
- AAD group membership / Desktop Virtualization User on AGs
- FSLogix profile housekeeping / redirection XML apply
- Agent VMSS
- Azure Policy initiatives (full Secure-Hub FW rules workstream)
- Private Endpoints / Private DNS (legacy 1.0 never had them)
- MSH 3-rule UDR redesign vs classic `default-to-firewall` (post-vWAN choice)

**Post-vWAN DNS (keep):** lab/mgmt spokes use corporate DNS `10.19.96.1` / `10.19.97.1`.

**Already at good parity:**

- PERS/MSH NSG custom rules (incl. 01i RPA / 01k–01l thin)
- PERS `default-to-firewall` route table
- MSH 3-rule UDR scaffold
- FSLogix **share names/quotas** (int RTL 100 GB; prd hostpool quotas incl. 005-01 = 51200) — **placement** still wrong (1 STA)
- MSH 30 host pools + per-BU scaling/decom catalog
- Gallery ~50 image definitions
- Hub shells + empty/stub firewall policy
- MSH Pooled / BreadthFirst / Desktop / `startVMOnConnect=false`

---

## Source verification (2026-07-26)

Re-checked against: all **30** `legacy/mult/.../params/hostpools/*.json`, `RDPProperties.json`, `vdi_hp_resources.bicep`, `vdi_workspace.bicep`, `sa_fslogix.bicep` / `rsg_storage.bicep`, lab/mgmt `params-netsec.json`, `params/*/01/law|alerts|mgmt`, `scripts/.../New-VDIAVDHostpool*` + `VDI-New-Hostpool-Appgroup-Workspace.bicep`, `vdi_dcr.bicep`, `access.bicep`, `vdi_sub_roles.bicep`, `gallery_roles.bicep`.

### Verdict legend

| Tag | Meaning |
|---|---|
| **DO** | Legacy proven + TF wrong/missing → fix in C01–C15 (or Wave C) |
| **SOFTEN** | Mostly true; implement carefully |
| **DEMOTE** | Not proven as TF work / overstated / out of Wave A/B |
| **OK** | Already matches |

### Wave A (MSH AVD)

| Claim | Verdict | Proof |
|---|---|---|
| Per-pool `maxSessionLimit` 6/10/15/18; **0/30 = 16** | **DO** | All 30 JSON: 6×17, 10×1, 15×7, 18×5 |
| Per-pool RDP profile MULT-* → `RDPProperties.json` | **DO** | JSON + PS stringify + Bicep |
| `validationEnvironment` true on **9** (`005-00` false) | **DO** | Exact canary set |
| `description` on all 30 | **DO** | All JSON |
| `agentUpdate` Sat 01:00 GMT Standard Time | **DO** | JSON + Bicep |
| Token `PT175H10M` on HP create | **DO** | Bicep exact; PS renew uses AddDays(27) — match Bicep |
| Workspace friendlyName int/prd | **DO** | `environment.json` |
| AG friendlyName `{BU} ({bu}-{pool})` | **DO** | `VDI_Environment_Helpers.psm1` |
| Scaling `exclusionTag = spExclude` | **DO** | Bicep both SPs |
| Scaling-plan diag `allLogs` → LAW | **DO** | `vdi_hp_resources.bicep` |
| MSH `startVMOnConnect = false` | **OK** | All 30 + TF default |
| Pooled / BreadthFirst / Desktop | **OK** | Bicep + JSON |
| Host-pool **inline** diagnostic settings | **DEMOTE** | Legacy HP→LAW is Policy DINE, not mult Bicep |

### Wave B (labs / storage / mgmt)

| Claim | Verdict | Proof |
|---|---|---|
| 10 FSLogix STAs (01a×6 + 01b×4) | **DO** | `p_FSLogixSta` int+prd |
| Shares on STA `…pf{bu}` | **DO** | naming + storage Bicep |
| Deny ACL + AVDSubnet + AgentsSubnet | **DO** | `sa_fslogix.bicep` |
| CMK + per-STA UAMI | **DO** | `rsg_storage` / `sa_kvkey` |
| AADKERB domainName + domainGuid | **DO** | `p_FSLogixSta` |
| SMB Kerberos / AES-256-GCM / SMB3.1.1 / multichannel | **DO** | `protocolSettings.smb` |
| `allowSharedKeyAccess: false`, `requireInfrastructureEncryption: true` | **DO** | Bicep property names |
| Public access + Deny ACL (no PE) | **SOFTEN** | PNA not explicit (API default Enabled); TF must not keep `false` without PE |
| File diags StorageRead/Write/Delete + Transaction | **DO** | `sa_fslogix` |
| Lab KVs Premium ×14 (2 Multi + 12 Pers) | **DO** | Priv = 15th — out unless labCorePriv |
| PERS blob STA ×12 Standard_LRS | **DO** | `labCorePersistent` |
| Lab AVD SE Storage+KeyVault | **DO** | lab params |
| AgentsSubnet SE | **SOFTEN** | On **mgmt**, not “lab Agents” |
| Mgmt NSG deny subnet CIDR | **DO** | vs TF VirtualNetwork tags |
| Mgmt `default-to-firewall` RT | **DO** | TF does not pass FW IP |
| FSLogix temp-VM STA RBAC | **DEMOTE** | maintenance path |
| Share SMB user RBAC / NTFS | **DEMOTE** | stays PS |

### PERS / Power On Off

| Claim | Verdict |
|---|---|
| PERS `startVMOnConnect` default **true** | **DO** (Wave D) — pipeline/PSM1/Bicep |
| WVD Power On Off on AVD + **MSH** labs | **DO** (Wave C) |
| WVD Power On Off on **PERS** labs | **DEMOTE / ask** — not in PERS create path |

---

## Execution chunks (C01–C15)

| Chunk | Scope | Status |
|---|---|---|
| C01 | This doc refresh | **done** |
| C02 | Per-pool max/RDP/validate/description | **done** |
| C03 | scheduled_agent_updates Sat 01:00 GMT | **done** |
| C04 | Token ~PT175H10M (175h) | **done** |
| C05 | Workspace + AG friendly names | **done** |
| C06 | Scaling exclusion_tag + allLogs diag | **done** |
| C07 | dummies-guide + validate avd | **done** |
| C08 | storage-fslogix module SMB/ACL model | **done** |
| C09 | 10 FSLogix STAs + share placement | **done** |
| C10 | STA ACLs + CMK | **done** — Deny ACLs + per-STA UAMI + RSA-4096 CMK on Multi Key Vaults |
| C11 | 14 lab Key Vaults | **done** — 2 Multi + 12 Personal, Premium, Deny ACLs |
| C12 | 12 PERS blob STAs | **done** — StorageV2 Standard_LRS, Deny ACLs |
| C13 | Service endpoints labs+mgmt | **done** |
| C14 | Mgmt NSG CIDR + firewall RT | **done** |
| C15 | validate labs+mgmt + READMEs | **partial** — validate green; README polish open |
| C16 | LAW resource-only permissions int/prd | **done** |
| C17 | MSH data collection rules + custom tables | **done** (definitions; VM associations stay PowerShell) |
| C18 | Alert action group + alert managed identity shell | **done** (rule templates still open) |
| C19 | Full alert rule templates | **open** |
| C20 | Platform RBAC (mgmt VM Contributor, gallery custom role support, WVD Power On Off hook) | **partial** — mgmt SP defaulted; gallery supports custom role id; WVD principal via tfvars |
| Wave D | Personal host pools | **open** |

---

## P0 — wrong or missing (C02–C15)

### MSH host pools

| Field | Legacy | TF (pre-fix) |
|---|---|---|
| `maxSessionLimit` | 6–18 per pool (0×16) | blanket 16 |
| `customRdpProperty` | MULT-* resolved | null |
| `validationEnvironment` | 9 canaries; 005-00 false | always false |
| `description` | all 30 | unset |
| `agentUpdate` | Sat 01:00 GMT | module gap |
| Registration token | Bicep `PT175H10M` | 24h |
| Workspace friendlyName | int DevTest… / prd Shared… | unset |
| AG friendlyName | `{BU} ({bu}-{pool})` | unset |
| Scaling exclusionTag | `spExclude` | module gap |
| Scaling-plan diags | `allLogs` → LAW | module gap |

### Labs / storage / mgmt

| Field | Legacy | TF (pre-fix) |
|---|---|---|
| FSLogix STA count / placement | 10; shares on `…pf{bu}` | 1 STA |
| Network ACLs / CMK / AADKERB domain | as Bicep | missing |
| SMB / shared key / infra enc / file diags | as Bicep | module gaps |
| `public_network_access` | implicit Enabled + Deny ACL | default false |
| Lab KVs | 14 Premium | not wired |
| PERS blob STA | ×12 | missing |
| Lab AVD + mgmt Agents SE | Storage + KeyVault | not passed |
| Mgmt NSG / RT | CIDR deny + default-to-firewall | VirtualNetwork deny / no RT |

---

## P1 Wave C — monitoring / RBAC backlog

### LAW

One workspace/env (`uks-{env}-vdi-avd-logs-law-01`). ops and secOps DCR labels → **same** ID. int `resourcePermissions=true`, prd `false`. Effective retention **30** (nested 31 unused).

### DCR / DCE

MSH (mult Bicep): `dcr-mult`, `dcr-mult-vminsights`, `dcr-multfslp`, `dcr-multwss`, `dce-mult-all` + `multfslp_CL`. PERS (scripts): default/pool/Robot/priv + `WSS_CL`. Associations stay with VMs. TF today: single Insights DCR+DCE in mgmt.

### Alerts (15 active)

AG `acg-DevicesLab` → `GRPG882932@nalloydsbanking.com`. APR pipeline-driven. UAMI `custom-log-alerts-msi` Reader for vCPU ARG. Templates enabled only when env contains `prd`. Skip commented Intune / old startfailed.

### RBAC — TF-worthy (platform only)

| Purpose | Role | Scope | Notes |
|---|---|---|---|
| DevOps ADA | VM Contributor | mgmt sub | int/prd SP IDs in `params-access.json` |
| Alert UAMI | Reader | mult + pers + broker | with alerts |
| WVD Power On Off | `40c5ff49-…` | AVD + **mult** lab subs | PERS labs: ask |
| Pipeline Privileged Contributor | file data | lab SA RG | if SP known to TF |
| Gallery Packer MSI | custom role GUID | gallery RG | assign existing |
| Lab KV CMK | Crypto Officer / Encryption User | lab KVs | with Wave B C10/C11 |
| FSLogix temp-VM STA roles | Elevated/KeyOp/Reader | STA | out until temp-VM TF |

**Stay PS:** AG Desktop Virtualization User, AAD membership, share SMB user RBAC, NTFS, session-host login.

### Decisions before Wave C

1. LAW retention: 30 (effective) or 31 (unused param)?
2. Keep int/prd `resourcePermissions` split?
3. Int alerts: deploy disabled or skip?
4. Hub/HP diag: TF vs Policy?
5. PERS DCR: default only until inventory?
6. Gallery custom role: assign GUID only?
7. PERS lab Power On Off: add anyway or MSH-only?

---

## P2 Wave D — backlog

- Fill `pers_host_pools`: Personal / Direct / Persistent / max 9999 / **`start_vm_on_connect = true`** / Desktop
- labCorePriv
- Untrack `legacy/` gitlinks from GitHub (`git rm -r --cached legacy/`)
- Naming PENDING(TDA)

---

## Repo hygiene — `legacy/` on GitHub

[`.gitignore`](../../.gitignore) has `legacy/`, but remote can still show nested **gitlinks** (mode `160000`). Ignore does not untrack indexed paths. When approved: `git rm -r --cached legacy/` then commit/push.

---

## Quick reference — env stack map

```text
_global          → vWAN
connectivity     → FWP stub, Hub01, Hub02 (VPN peer missing)
mgmt             → LAW + DCE + Insights DCR; alerts empty; NSG/RT gaps (C14)
labs             → PERS/MSH spokes; FSLogix share names OK; STA/KV/ACLs incomplete (C08–C13)
avd              → 30 MSH HP + scaling; RDP/max sessions wrong pre-C02–C06; PERS map empty
```
