# environments/igmf/connectivity

Connectivity subscription root for the **IGMF** sandbox (ignitemyfire.co.uk).

Deploys (gated by `enable_hub01` / `enable_hub02`, both default `true`):
- Connectivity resource group (always)
- Baseline Azure Firewall Policy (stub)
- Hub01 secured (AZFW + routing intent + ER gateway shell)
- Hub02 unsecured (VPN gateway shell — no peer)

Requires `virtual_wan_id` from `config/vwan` applied with state key `igmf/vwan.tfstate`.

## Pipelines

- [`pipelines/tf-igmf-release.yml`](../../../pipelines/tf-igmf-release.yml) — `stackName=connectivity`
- [`pipelines/tf-igmf-connectivity.yml`](../../../pipelines/tf-igmf-connectivity.yml) — plan then apply
- Prefer [`pipelines/tf-Hub-Deployment.yml`](../../../pipelines/tf-Hub-Deployment.yml) for hubSelection stages (bank + same pattern)

## Offline check

```bash
terraform init -backend=false
terraform validate
```

Copy `terraform.tfvars.example` → `terraform.tfvars` (gitignored) and fill `virtual_wan_id` after `vwan` apply.
