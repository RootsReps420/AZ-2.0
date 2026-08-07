# environments/_global

Root configuration for resources deployed **once** and shared across all
regions and environments. Currently deploys the global **Virtual WAN** and its
resource group.

This folder is **configuration only** — variable values plus calls to
`modules/`. No logic lives here.

## Deploys

- `azurerm_resource_group` — global resource group (named via `modules/naming`)
- Virtual WAN via [`modules/platform/vwan`](../../modules/platform/vwan)
- Tags via [`modules/tags`](../../modules/tags)

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # then edit values

terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=sttfstatevdi" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=_global.tfstate"

terraform plan
terraform apply
```

## Outputs

| Name | Description |
|------|-------------|
| `vwan_id` | Global Virtual WAN resource ID (referenced by per-region hub deployments) |
| `vwan_name` | Global Virtual WAN name |
| `global_resource_group_name` | Global resource group name |
