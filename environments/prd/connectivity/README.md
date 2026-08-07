# environments/prd/connectivity

Connectivity subscription root for **prd**.

Composition:

| Hub | Module | Role | Default prefix | Deployed? |
|---|---|---|---|---|
| Hub01 | `hub-secured` | AZFW + Routing Intent + ExpressRoute | `10.218.64.0/22` | Yes |
| Hub02 | `hub-unsecured` | VPN gateway shell (MSH path) | `10.218.68.0/22` | Yes |
| Hub03 | `hub-spare` | Bare spare (no FW/VPN/ER/spokes) | `10.218.72.0/22` | **No** — module commented out; CIDR kept in `var.hub03_address_prefix` |

Plus baseline firewall policy (DNS proxy on; rule collections stub).

Hub modules are gated by `enable_hub01` / `enable_hub02` (default `true`) for phased pipeline deploys — one state key `prd/connectivity.tfstate`.

To enable Hub03 later (any region): uncomment `module "hub_spare"` and `output "hub03_id"` in this stack. The module is region-agnostic (`location`).

**int** remains two-hub (`10.170.245/246`) — see `docs/address-plan-hubs.md`.

```bash
terraform init -backend=false
terraform validate
```
