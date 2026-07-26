# AzTF_vWAN

Monorepo for Terraform.
Developing Purely in this monorepo for Personal Development
Main goal is to expand Module knowledge along with improving IaC via Terraform (Testing object capabilities of state file will also be carried out for VM creation)

## Plans

Build and migration plans are versioned under [`docs/plans/`](docs/plans/README.md):

- [01 - VDI Terraform Platform Buildout](docs/plans/01-vdi-terraform-buildout.md) - greenfield module + environment build (Complete)
- [02 - Azure 1.0 to Terraform Migration](docs/plans/02-azure-1.0-to-terraform-migration.md) - porting the legacy estate onto the Terraform modules (**scaffold complete** — offline validate; live apply when creds ready)
- [03 - Cursor account handoff](docs/plans/03-cursor-handoff.md) - context / locked decisions / prompt history for continuing on another Cursor account
- [04 - Gap analysis legacy vs TF](docs/plans/04-gap-analysis-legacy-vs-tf.md) - legacy↔TF parity status (**complete**)

## Useful entry points

| Path | Purpose |
|---|---|
| [`docs/dummies-guide.md`](docs/dummies-guide.md) | **Start here** — as-built LLD: architecture diagrams, module catalogue, DevOps vs legacy scripts, CIDRs/routes/AVD/storage/wiring |
| [`docs/lld-terraform-summary.md`](docs/lld-terraform-summary.md) | Original Terraform LLD (Word) summarised |
| `environments/int/*` | First live target (DT) — connectivity / mgmt / labs / avd |
| `environments/prd/*` | Production (prd) mirrors |
| `pipelines/` | AzDo Terraform init/plan/apply |
| `docs/variable-set.md` | Tags / DNS / GUIDs for tfvars |
| `docs/address-plan-hubs.md` | Hub/spoke CIDRs |

Apply order: `_global` → `connectivity` → `mgmt` → `labs` → `avd`.
