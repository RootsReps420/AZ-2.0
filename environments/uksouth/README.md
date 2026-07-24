# Superseded environment roots

`environments/uksouth/{dev,prod}` were the greenfield single-root demos.

They are **superseded** by the migration layout:

```
environments/_global/                 # shared Virtual WAN
environments/int/{connectivity,mgmt,labs,avd}/   # DT — first live target
environments/prd/{connectivity,mgmt,labs,avd}/   # production (TDA code prd)
```

Do not deploy from `uksouth/` for the Azure 1.0 cutover. Prefer `int` / `prd` per-scope roots.
These folders may be removed once `int`/`prd` stacks fully replace the greenfield demos.
