# modules/platform/hub-spare

Blueprint for **Hub03 — a spare / bare Virtual Hub** attached to a shared Virtual
WAN. No Azure Firewall, Routing Intent, ExpressRoute gateway, or VPN gateway.
No spoke connections.

**Not wired from env roots today.** `environments/prd/connectivity` keeps the
module call **commented out** and retains reserved CIDR
`hub03_address_prefix` (default `10.218.72.0/22`). Uncomment that block (and
`hub03_id` output) when a region needs the spare hub. Region-agnostic via
`location`.

Azure allows creating an empty hub and adding gateways later; empty-hub pricing
still applies when deployed. If used later, private traffic can traverse
**Hub01** Azure Firewall via Routing Intent. Until then there is no Azure
resource and no live VDI path.

## Azure resources (when enabled)

- `azurerm_virtual_hub`

## Depends on

- Virtual WAN ID from `modules/platform/vwan` (`vwan_id`)

## Outputs

- `hub_id` — no consumers yet (future spoke / gateway attachment)
- `hub_name`

See [`examples/basic`](examples/basic) for usage.
