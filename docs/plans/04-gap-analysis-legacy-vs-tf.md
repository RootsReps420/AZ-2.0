# Gap analysis — legacy Azure 1.0 vs Terraform

**Status:** Complete (C01–C20 + Wave D + labCorePriv + README polish). Deploy-time principal/subscription IDs remain tfvars.  
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
- Privileged **local** Azure Firewall (legacy labCorePriv AZFW) — Hub01 is next hop
- Robot personal (RDP broker, not AVD)
- Naming PENDING(TDA) — abbreviations awaiting bank naming board

**Post-vWAN DNS (keep):** lab/mgmt spokes use corporate DNS `10.19.96.1` / `10.19.97.1`.

---

## Execution chunks (C01–C20 + Wave D)

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
| C10 | STA ACLs + CMK | **done** |
| C11 | Lab Key Vaults (now 15 with Priv) | **done** |
| C12 | 12 PERS blob STAs | **done** |
| C13 | Service endpoints labs+mgmt | **done** |
| C14 | Mgmt NSG CIDR + firewall RT | **done** |
| C15 | validate labs+mgmt + READMEs | **done** |
| C16 | LAW resource-only permissions int/prd | **done** |
| C17 | MSH data collection rules + custom tables | **done** (VM associations stay PowerShell) |
| C18 | Alert action group + alert managed identity shell | **done** |
| C19 | Full alert rule templates + APR + UAMI Reader | **done** (sub IDs / share scopes in tfvars at deploy) |
| C20 | Platform RBAC hooks | **done** (principals in tfvars) |
| Wave D | Personal host pools (10) | **done** |
| Wave D+ | labCorePriv spoke + PRIV host pool | **done** (Hub01 RT; no local AZFW) |
| Hygiene | Untrack `legacy/` gitlinks | **done** (index; push when you choose) |

---

## Deploy-time leftovers (not code gaps)

| Item | Where |
|---|---|
| Alert mult / pers / broker subscription GUIDs | `environments/*/mgmt` tfvars |
| FSLogix file-share scopes for metric alerts | mgmt `alert_fslogix_file_shares` from labs outputs |
| Gallery Packer MSI object IDs + custom role GUIDs | avd `gallery_role_assignments` (GUIDs documented in tfvars.example) |
| WVD Power On Off SP object ID + mult lab subs | avd `wvd_power_on_off_*` |

---

## Quick reference — env stack map

```text
_global          → vWAN
connectivity     → FWP stub, Hub01, Hub02 (VPN peer still placeholder); Hub03 spare in code only (not deployed)
mgmt             → LAW + DCE + Insights DCR; alerts + APR/Reader; NSG/RT
labs             → PERS/PRIV/MSH spokes; 10 FSLogix STAs; 15 KVs; 12 PERS blobs
avd              → 30 MSH + 10 PERS + 1 PRIV HP; gallery/WVD RBAC via tfvars
```
