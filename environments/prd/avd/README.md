# environments/prd/avd

MSH pooled host pools + **per-BU scaling plans** (30 pools) with shared schedule catalog.

- BU **005** uses `*_005` / `*_005_canary` schedules
- Pool `-00` canaries use `*_canary`
- Sibling `-decom` scaling plan per pool (disabled by default)

Sources: `legacy/mult/vdi-mult/params/scalingPlanSchedules*.json` + `hostpools/*.json`

```bash
terraform init -backend=false
terraform validate
```
