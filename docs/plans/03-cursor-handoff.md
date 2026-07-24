# Cursor account handoff — AzTF / vWAN VDI Terraform

**Purpose:** Paste or attach this into another Cursor chat so work continues without re-deriving context.  
**Workspace:** `c:\Repos\TerraformShit` (personal monorepo; intended eventual `vdi-terraform`).

**Prior chat transcript (this machine):** agent id `957df4c1-9405-4eaa-8afa-f0978cafbff0` — full JSONL under Cursor agent-transcripts if needed.

**Privacy:** Cursor Privacy Mode is on — do **not** treat `legacy/` as training material. Keep `legacy/` **local-only** (already in `.gitignore`; nested gitlinks may still be on GitHub until untracked — open gap-audit plan step 0).

---

## North star (end goal)

Terraform that lives in a **managed GitHub repo**, deployed via **Azure DevOps**, producing a **two-hub Azure Virtual WAN** platform for AVD (~25k colleagues: ~18k PERS personal + MSH pooled by BU):

| Hub | Role |
|---|---|
| **Hub01 secured** | PAA + PERS personal desktops; Azure Firewall + Routing Intent + ExpressRoute |
| **Hub02 unsecured** | TSA / MSH internet via VPN toward Palo Alto Proxy; MSH spokes use UDRs |

**TF owns:** WAN, hubs, baseline FWP stub, LAW/mgmt spoke, lab spokes (NSG/UDR), FSLogix **storage**, AVD objects (HP/AG/WS/scaling), gallery **definitions**, KV shells, AzDo TF pipelines.

**Stays PowerShell:** session-host VMs, Packer **versions**, token consume, AAD/Desktop Virtualization User, FSLogix profile ops, agent VMSS, decom/power/disk/ADE.

**Auth:** same AzDo SPNs / service connections / private agents for now (GLB decoupling deferred).

**First live target:** `int` (DT). Production env code is **`prd`** (TDA), folder `environments/prd/`.

**Apply order:** `_global` → `connectivity` → `mgmt` → `labs` → `avd`.

---

## Locked decisions (do not reopen unless asked)

- **Naming:** TDA everywhere for TF resources.
- **Topology:** multi-sub split (conn / mgmt / avd / lab); env roots per stack; drop `ppd`; keep `idv/ici/itt/int` split for now; **`prd` not `prod`**.
- **IPs:** carry legacy CIDRs verbatim where possible; Hub02 int=`10.170.246.0/24`, prd=`10.170.244.0/24` (not 248 — collides with PERS 01l). See [address-plan-hubs.md](../address-plan-hubs.md).
- **DNS:** `10.19.96.1`, `10.19.97.1`.
- **VMs never in TF** (state-file / lifecycle reasons).
- **Full AZFW rules → Azure Policy** (separate workstream); TF ships empty/stub FWP only.
- **Hub02 VPN peer** still written by another engineer — GW scaffold only.
- **MSH `0.0.0.0/0` next-hop:** `PENDING(LLD)`.
- **Offline only:** `terraform fmt` / `validate` until creds ready — no live `plan`/`apply` without user asking.
- **INT FSLogix = RTL cheap** (100 GB shares); **PRD = legacy quotas exact** (incl. 005-01 = 51200).
- **NSGs must match legacy exactly** (PERS per-lab variance; MSH VNet-scoped 4-rule on every subnet).

---

## Key source docs (read these first in the new chat)

| Path | Why |
|---|---|
| [dummies-guide.md](../dummies-guide.md) | Simple architecture + placeholders |
| [02-azure-1.0-to-terraform-migration.md](02-azure-1.0-to-terraform-migration.md) | Main migration plan (scaffold complete) |
| [04-gap-analysis-legacy-vs-tf.md](04-gap-analysis-legacy-vs-tf.md) | Remaining parity gaps + waves A–D (**under review**) |
| [lld-terraform-summary.md](../lld-terraform-summary.md) | LLD extract |
| [address-plan-hubs.md](../address-plan-hubs.md) | Hub/spoke CIDRs |
| [variable-set.md](../variable-set.md) | Tags / DNS / GUIDs |
| [pipelines/README.md](../../pipelines/README.md) | AzDo TF deploy |
| LLD Word (authoritative) | `C:\Users\Dan\Documents\terraform low level design .docx` |
| TDA naming Word | `C:\Users\Dan\Documents\TDA Approved Azure Resource Naming.docx` |
| Local legacy clones | `legacy/{platform,pers,mult,scripts,images,initiatives,libraries}` — **gitignored / must stay off GitHub** |

Open Cursor plans (this machine under `C:\Users\Dan\.cursor\plans\`):

- `prd_nsg_pers_routes_*.plan.md` — **executed** (prd rename, NSGs, PERS RT, FSLogix quotas)
- `legacy_tf_gap_audit_*.plan.md` — **pending review** (untrack legacy + Wave A/B gaps) — do not execute until Dan says go

---

## What is already built (as of handoff)

- Modules: naming, tags, vwan, hub-secured, hub-unsecured, firewall-policy, management, spoke-pers, spoke-msh, storage-fslogix, keyvault, hostpool, workspace, scalingplan, gallery + image-definition.
- Env stacks: `_global`, `int/*`, `prd/*` (connectivity, mgmt, labs, avd).
- Labs: PERS 01a–01l + MSH 01a/01b; **legacy-exact NSG rules**; PERS default-to-firewall RT; FSLogix share maps (int 100GB / prd hostpool quotas).
- AVD: 30 MSH pools + scaling/decom; gallery ~50 defs; `pers_host_pools` still `{}`.
- Pipelines: `tf-release.yml` uses envName `int` \| `prd`.
- Offline validate green on key stacks.

**Known incomplete (next work — still under review):** [04-gap-analysis-legacy-vs-tf.md](04-gap-analysis-legacy-vs-tf.md) — per-pool max sessions/RDP still wrong (blanket 16); multi-STA FSLogix; lab KVs; service endpoints/ACLs; alerts/DCRs; untrack legacy gitlinks from GitHub.

---

## Condensed prompt history (what the user asked for)

Chronological themes — use as intent, not as commands to re-run blindly:

1. **Explain codebase / LLD** — Attach TDA naming + Terraform LLD Word docs; build greenfield module + env platform for region-agnostic AVD vWAN.
2. **Phase build** — Build one phase at a time (`go` repeatedly through Phase 0–H scaffold).
3. **Import Azure 1.0** — Map Bicep/PS/pipelines → TF; VMs stay PS; SPNs stay; IPs stay; TDA rename; put legacy under `legacy/` (local only; Privacy Mode).
4. **Drop ppd**; keep `idv/ici/itt/int` split; **`int` = DT**.
5. **Diagrams** of new codebase layout; store plans under `docs/plans/`.
6. **No live terraform plan** until creds — validate/fmt only.
7. **Triple-check** functional-ish vWAN; explicitly defer AZFW→Policy, Hub02 VPN peer, GLB.
8. **MSH scaling per BU/host pool** (not one global SP) + decom siblings.
9. **IP double-check** then execute migration scaffold.
10. **Dummy’s guide** for humans.
11. **prd rename + NSGs + PERS routes + FSLogix quotas** — NSGs must match legacy exactly (PERS variance 01i/01k/01l; MSH per-lab VNet-scoped); INT RTL 100GB; PRD exact quotas; update READMEs → **executed**.
12. **Gap audit** — compare everything TF-worthy in legacy vs TF (excl. VMs + hub→vWAN already done); double/triple check → open plan with Wave A/B (**still reviewing — do not execute yet**).
13. **Untrack `legacy/` from GitHub** — already in `.gitignore` but gitlinks (160000) still on remote → gap plan step 0.
14. **This handoff** — write prompts/context/goal for another Cursor account.

---

## Suggested first message on the other account

```text
Continue the AzTF vWAN / Azure 1.0→Terraform work in c:\Repos\TerraformShit.

Read docs/dummies-guide.md, docs/plans/02-azure-1.0-to-terraform-migration.md,
docs/plans/03-cursor-handoff.md, and docs/plans/04-gap-analysis-legacy-vs-tf.md.

Privacy Mode is on — do not treat legacy/ as training material; keep it local-only.
Do not terraform plan/apply without my say-so (validate/fmt only).
VMs stay PowerShell. Env code is prd not prod. INT FSLogix is RTL 100GB; PRD is exact.

Gap analysis waves A–D are still under review — do not execute until I say go.
Ask me what to do next.
```

---

## Working conventions for the other agent

- Prefer editing existing modules/env stacks; update affected READMEs.
- Match legacy **exactly** for anything TF owns (NSG, quotas, max sessions, RDP props) — don’t invent “nice defaults”.
- Ask before committing/pushing unless the user explicitly requests.
- Plan mode vs execute: only implement when the user clearly says go/execute.
- Obsolete `environments/prod` may still exist locked beside `prd` — delete when unlocked; use `prd`.
