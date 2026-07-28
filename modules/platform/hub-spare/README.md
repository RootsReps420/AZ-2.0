# modules/platform/hub-spare

Deploys **Hub03 — a spare / bare Virtual Hub** attached to the shared Virtual
WAN. No Azure Firewall, Routing Intent, ExpressRoute gateway, or VPN gateway.
No spoke connections today.

Azure allows creating an empty hub and adding gateways later; empty-hub pricing
still applies. Purpose: reserve address space and vWAN mesh membership so that,
if this hub is ever used, private traffic can traverse **Hub01** Azure Firewall
via Routing Intent. Until something attaches, this is reservation + mesh only —
not a live VDI path.

## Azure resources

- `azurerm_virtual_hub`

## Depends on

- Virtual WAN ID from `modules/platform/vwan` (`vwan_id`)

## Outputs

- `hub_id` — no consumers yet (future spoke / gateway attachment)
- `hub_name`

See [`examples/basic`](examples/basic) for usage.
