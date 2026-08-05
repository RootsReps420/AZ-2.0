# modules/core/spoke-msh

Deploys an **MSH (multi-session host) workload spoke**. Connects to **Hub01**
and overrides Hub01 Routing Intent with an explicit three-rule UDR (internet
next-hop aimed at Hub02 VPN once that peer exists).

> Azure limit: one VNet → one virtual hub. A second connection to Hub02 returns
> `VirtualNetworkIsAlreadyConnectedToAnotherHub`. Hub02 VPN reachability is
> hub-to-hub via the Hub01 connection, not a dual `hubVirtualNetworkConnection`.

> Complexity note (LLD §4.3): three-rule UDR + Hub02 VPN next-hop still under
> **senior-engineer review** (Open Item 5).

## The three-rule UDR

| Destination | Next hop |
|-------------|----------|
| `0.0.0.0/0` | Hub02 VPN Gateway (`default_route_next_hop_type`, internet via Palo Alto Proxy) |
| Service Tags (`service_tag_routes`) | Hub01 Firewall Private IP |
| RFC1918 (`rfc1918_prefixes`) | Hub01 Firewall Private IP |

## Azure resources

- `azurerm_virtual_network`, `azurerm_subnet` (per `subnets`)
- `azurerm_network_security_group` + association (per subnet; optional `security_rules` — labs pass legacy VNet-scoped Multi rules)
- `azurerm_route_table` (three-rule UDR) + subnet associations
- `azurerm_network_watcher` (when `create_network_watcher`)
- `azurerm_virtual_hub_connection` ×1 (Hub01 only)

## Depends on

- `hub01_id`, `hub01_firewall_private_ip` — from `modules/platform/hub-secured`
- `hub02_id` — from `modules/platform/hub-unsecured`

## Outputs

`vnet_id`, `vnet_name`, `subnet_ids`, `nsg_ids`, `route_table_id`,
`hub01_connection_id`, `hub02_connection_id`.

> Open Item 5: Palo Alto Proxy VPN endpoint must be confirmed before real egress.

See [`examples/basic`](examples/basic) for usage.
