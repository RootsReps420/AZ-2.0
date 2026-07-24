# modules/core/spoke-pers

Deploys a **PERS (personal desktop) workload spoke**. Connects to **Hub01 only**.

When `hub01_firewall_private_ip` is set, creates the legacy **default-to-firewall**
route table (`0.0.0.0/0` → VirtualAppliance, BGP propagation disabled) and
associates it to subnets with `associate_route_table = true` (default).

## Azure resources

- `azurerm_virtual_network`
- `azurerm_subnet` (per `subnets`)
- `azurerm_network_security_group` + association (per subnet; optional `security_rules`)
- `azurerm_route_table` + association (when `hub01_firewall_private_ip` is set)
- `azurerm_network_watcher` (when `create_network_watcher`)
- `azurerm_virtual_hub_connection` (to Hub01)

## Depends on

- `hub01_id` — output `hub_id` from `modules/platform/hub-secured`
- `hub01_firewall_private_ip` (optional) — Hub01 AZFW private IP for the legacy UDR

## Outputs

- `vnet_id`, `vnet_name`
- `subnet_ids` — consumed by AVD / Key Vault / storage modules
- `nsg_ids`, `hub_connection_id`
- `route_table_id` — null when no firewall IP was supplied

See [`examples/basic`](examples/basic) for usage.
