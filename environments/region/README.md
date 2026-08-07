# environments/region

Per-region **values** for env × stack deploys. Stack code stays under
`environments/<env>/<stack>/`.

## Layout

```text
environments/region/<location>/<env>.<stack>.tfvars
```

### uksouth connectivity (first slice — all three tenants)

| File | Env |
|---|---|
| [`uksouth/int.connectivity.tfvars`](uksouth/int.connectivity.tfvars) | int |
| [`uksouth/prd.connectivity.tfvars`](uksouth/prd.connectivity.tfvars) | prd |
| [`uksouth/igmf.connectivity.tfvars`](uksouth/igmf.connectivity.tfvars) | igmf |

Pipelines pass `-var-file=environments/region/<location>/<env>.<stack>.tfvars` when present,
then `-var=location=<location>` (and hub flags for connectivity).

### Tags

Resources get tags from `modules/tags` (platform keys auto-applied). Regional tfvars only
supply `mandatory_tags` (four bank keys the module still requires as inputs). Do not paste
legacy cost-centre / owner strings — use current standard values (or `TODO` until known).
