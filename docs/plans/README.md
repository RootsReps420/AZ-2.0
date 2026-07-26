# Migration & Build Plans

Versioned record of the major planning efforts for the VDI Terraform platform.
Each plan is captured as a standalone markdown doc so the history and rationale
live in the repo (the live working copies are authored in Cursor's plan mode).

## Index

| # | Plan | Status | Summary |
|---|------|--------|---------|
| 01 | [VDI Terraform Platform Buildout](01-vdi-terraform-buildout.md) | Complete | Greenfield build of the full module catalogue (naming, tags, platform, core, avd, gallery) + `_global` and `uksouth/{dev,prod}` environment roots. |
| 02 | [Azure 1.0 to Terraform Migration](02-azure-1.0-to-terraform-migration.md) | Scaffold complete | Port the legacy Azure 1.0 estate onto Terraform modules; re-platform hub-peering to vWAN; TDA naming; multi-subscription topology preserved. Phases 0–H scaffolded (offline validate). Live apply blocked on creds + deferred Hub02 VPN / AZFW Policy / GLB. Phase 0 inventory: [live](../legacy-live-inventory.md) · [dead](../legacy-dead-code.md) · [pipeline fate](../legacy-pipeline-fate.md). |
| 03 | [Cursor account handoff](03-cursor-handoff.md) | Current | Context, locked decisions, prompt history, and starter message for continuing work on another Cursor account. |
| 04 | [Gap analysis — legacy vs TF](04-gap-analysis-legacy-vs-tf.md) | In progress | Source-verified gaps; C01–C15 Wave A/B execution; Wave C/D backlog pending decisions. |

## Conventions

- Plans are numbered in the order they were created.
- Status: `Planned` -> `In progress` -> `Complete`.
- Diagrams use Mermaid so they render in GitHub / Cursor.
- When a plan is superseded, keep the file and note the successor at the top.
