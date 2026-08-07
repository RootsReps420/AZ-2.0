# environments/int/connectivity

Connectivity subscription root for **int** (DT / dev test).

Deploys (gated by `enable_hub01` / `enable_hub02`, both default `true`):
- Connectivity resource group (always)
- Baseline Azure Firewall Policy (stub — full rules deferred to Azure Policy workstream)
- Hub01 secured (AZFW + routing intent + ER gateway)
- Hub02 unsecured (VPN gateway scaffold — peer/site deferred)

Requires `virtual_wan_id` from `environments/_global`.

Phased first deploy: Hub01 only (`enable_hub02=false`), then both true. Narrowing a flag plans destroy of that hub. One state key: `int/connectivity.tfstate`.

## Offline check

```bash
terraform init -backend=false
terraform validate
```

Do not `plan`/`apply` until subscription GUIDs + auth are ready.
