# modules/tags

**Sole source of Azure resource tags** for this repo. Pure computation (no Azure
resources): merges bank mandatory tags with platform tags into one map. Every
stack root calls this module and passes `tags = module.tags.tags` (or
`tags_pers` / `tags_mult` / `tags_priv`) to resources. Resource modules only
forward that map — they never invent tag keys.

## Mandatory catalog (every resource)

| Key | Source |
|---|---|
| `costCentre` | tfvars → `mandatory` |
| `securityClassification` | tfvars → `mandatory` |
| `resourceOwner` | tfvars → `mandatory` |
| `CMDB_AppID` | tfvars → `mandatory` |
| `environment` | caller → module |
| `region` | caller (`location`) → module |
| `workload` | lane → module map (`vdi-*`) |
| `managed-by` | module constant `terraform` |
| `repo` | module constant `vdi-terraform` |

No optional / additional tags.

## Workload lanes

Callers pass a **lane**; this module owns the Azure tag string:

| `workload` input | Tag value | Typical use |
|---|---|---|
| `platform` | `vdi-platform` | vwan, connectivity, mgmt |
| `pers` | `vdi-pers` | labs PERS; avd PERS objects |
| `mult` | `vdi-mult` | labs MSH; avd MSH + shared KV/gallery |
| `priv` | `vdi-priv` | labs PRIV; avd PRIV objects |

## Usage

```hcl
module "tags" {
  source = "../../modules/tags"

  workload    = "platform" # lane — not the vdi-* string
  environment = var.environment
  region      = var.location
  mandatory   = var.mandatory_tags
}

# tags = module.tags.tags
```

AVD / labs with multiple lanes: call the module three times (`tags_mult`,
`tags_pers`, `tags_priv`) with lanes `mult` / `pers` / `priv`.

## Inputs

| Name | Description | Type |
|------|-------------|------|
| `mandatory` | Bank tags (typed object) | `object` |
| `workload` | Lane: `platform` \| `pers` \| `mult` \| `priv` | `string` |
| `environment` | `environment` tag | `string` |
| `region` | `region` tag | `string` |

## Outputs

| Name | Description |
|------|-------------|
| `tags` | Full mandatory tag map |
