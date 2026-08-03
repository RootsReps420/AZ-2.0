# environments/igmf/connectivity

Connectivity subscription root for the **IGMF** sandbox (ignitemyfire.co.uk).

Deploys:
- Baseline Azure Firewall Policy (stub)
- Hub01 secured (AZFW + routing intent + ER gateway shell)
- Hub02 unsecured (VPN gateway shell — no peer)

Requires `virtual_wan_id` from `environments/_global` applied with state key `igmf/_global.tfstate`.

## Pipelines

- [`pipelines/tf-igmf-release.yml`](../../../pipelines/tf-igmf-release.yml) — `stackName=connectivity`
- [`pipelines/tf-igmf-connectivity.yml`](../../../pipelines/tf-igmf-connectivity.yml) — plan then apply

## Offline check

```bash
terraform init -backend=false
terraform validate
```

Copy `terraform.tfvars.example` → `terraform.tfvars` (gitignored) and fill `virtual_wan_id` after `_global` apply.
