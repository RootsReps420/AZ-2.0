# environments/region

Per-region **values** for env × stack deploys. Stack code stays under
`environments/<env>/<stack>/`.

## Layout

```text
environments/region/<location>/<env>.<stack>.tfvars
```

### connectivity (int / prd / igmf × three locations)

| Location | Files |
|---|---|
| [`uksouth/`](uksouth/) | `int` / `prd` / `igmf` `.connectivity.tfvars` (hub CIDRs filled for bank/IGMF) |
| [`italynorth/`](italynorth/) | same three — hub CIDRs blank until address plan |
| [`spaincentral/`](spaincentral/) | same three — hub CIDRs blank until address plan |

Pipelines: workdir `environments/<env>/<stack>`, `-var-file` this path when present,
then `-var=location=<location>`.

### Tags / naming

- `mandatory_tags` for int/prd: `430034` / `Limited` / `VirtualTeam` / `AL17611`
- IGMF: sandbox keys (`IGMF-SANDBOX` / `IGMF001` / …)
- Platform tags (`managed-by`, `environment`, `region`, `workload`, `repo`) come only from [`modules/tags`](../../modules/tags) — callers pass a workload **lane** (`platform` / `pers` / `mult` / `priv`), not the `vdi-*` string
- `environment`, `location`, `subscription_code` also feed `modules/naming`
