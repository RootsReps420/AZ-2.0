# environments/prd/connectivity

Connectivity subscription root for **prd**.

Same composition as `environments/int/connectivity` with prd address ranges from `params/prd/config.yml`.

```bash
terraform init -backend=false
terraform validate
```
