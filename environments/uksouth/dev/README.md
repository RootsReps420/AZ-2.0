# environments/uksouth/dev

Region/environment root for **UK South (dev)**. Configuration only — variable
values plus module calls. All logic lives in `modules/`.

## Deploys

- **Connectivity platform**: firewall policy, Hub01 (secured), Hub02 (unsecured),
  management workspace (LAW + AVD Insights DCR)
- **PERS lab**: spoke (Hub01 only), Key Vault, FSLogix storage, personal host
  pool, workspace, personal scaling plan
- **MSH lab**: spoke (dual-hub + 3-rule UDR), pooled host pool, workspace
- **Images**: compute gallery + PERS and MSH base image definitions

The global Virtual WAN lives in [`config/vwan`](../../../config/vwan); pass its
`vwan_id` output into `var.virtual_wan_id`.

## Region agnostic

Everything is driven by `var.location`. To deploy another region, use that
region's root folder (e.g. `environments/italynorth/dev`) with the same module
calls — naming and tagging adapt automatically.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # then edit values

terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=sttfstatevdi" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=uksouth-dev.tfstate"

terraform plan
terraform apply
```

## Providers

Requires `azurerm` (`>= 4.0.0, < 5.0.0` — the code uses 4.x-only arguments),
`time`, and `azapi` (the last for AVD personal scaling schedules).

## Pre-deployment fill-in checklist

Inline markers make every fill-in point greppable. Before `terraform apply`:

```bash
# List everything an engineer must supply/decide before this deploys usefully:
grep -rn "TODO(deploy)" .

# List governance placeholders awaiting external sign-off:
grep -rn "PENDING(TDA)\|PENDING(LLD)" ../../..
```

Known `TODO(deploy)` items in this environment:

- `terraform.tfvars`: real `azure_subscription_id`, `virtual_wan_id`, and
  `mandatory_tags` (the example uses placeholder `CC-4821` / `example.com`).
- `module.firewall_policy`: no rule collection groups are set, so with Hub01
  Routing Intent **egress is default-deny**. Add baseline AVD allow rules.
- `module.keyvault_pers`: `unique_id` must be a globally-unique 7-char id.
- `module.storage_fslogix_pers`: AADKERB also needs tenant Entra Kerberos
  enablement + per-user storage RBAC (not managed here).
- `module.hub_secured`: set `expressroute_circuit_peering_id` to connect a
  circuit (null = gateway only).

## Session hosts (VMs are NOT built by Terraform)

Session-host VMs are intentionally **not** managed by Terraform, so there is no
session-host module in this repo. Production holds 20,000+ VMs, which is beyond
what a single Terraform state file should hold (slow plans, lock contention,
large blast radius). VMs are provisioned by **pipeline tooling** that consumes
the host pool `registration_token` output (from
[`modules/avd/hostpool`](../../../modules/avd/hostpool)).

To make a session host actually function via that pipeline, the following
platform gaps still apply:

- **Baseline firewall allow rules** on `module.firewall_policy` (AVD service
  tags/FQDNs, KMS activation, Entra/Kerberos, storage) — see the default-deny
  note above.
- **FSLogix name resolution**: storage private endpoint +
  `privatelink.file.core.windows.net` private DNS zone (or equivalent).
- **RBAC**: "Virtual Machine User/Administrator Login" on the session-host RG,
  "Desktop Virtualization User" on the app group (so users see the desktop), and
  "Storage File Data SMB Share Contributor" on the FSLogix share.
- **Image versions** are published by Packer (out of Terraform scope; the
  gallery module manages definitions only).
