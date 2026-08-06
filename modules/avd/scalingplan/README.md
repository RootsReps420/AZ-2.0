# modules/avd/scalingplan

Deploys an **AVD Scaling Plan**, associates it with host pools, and defines its
schedules for power management.

## Azure resources

- **Pooled** (`pooled_schedules` set): `azurerm_virtual_desktop_scaling_plan`
  (+ `host_pool` associations + pooled `schedule` blocks)
- **Personal** (`personal_schedules` only): `azapi` scaling plan with
  `hostPoolType=Personal` + host pool references
- `azapi_resource` — `…/scalingPlans/personalSchedules` (per `personal_schedules`)

## Why azapi for personal plans / schedules

azurerm (<= 4.x) only creates **Pooled** scaling plans. Personal host pools
require `hostPoolType=Personal` (immutable), so PERS/PRIV plans are created via
`azapi`. Personal schedule children are also `azapi` (no native azurerm type).
The `properties` object in each `personal_schedules` entry is passed straight
through to the ARM body — see the example for the shape.

Pooled schedules continue to use the native azurerm `schedule` block.

**Note:** Azure allows only **one** scaling plan association per host pool
(even when disabled). Do not attach both a standard and a decom sibling to the
same pool in Terraform.

## Providers

Requires **azapi `>= 2.0`** in addition to azurerm. Root configs/examples using
personal schedules must declare and configure the `azapi` provider.

## Depends on

- `host_pool_associations[*].hostpool_id` — output `hostpool_id` from
  `modules/avd/hostpool`

## Outputs

`scaling_plan_id`, `scaling_plan_name`, `personal_schedule_ids`.

> Abbreviation `vdsp` is PENDING TDA sign-off (LLD Open Item 2).

See [`examples/basic`](examples/basic) for usage.
