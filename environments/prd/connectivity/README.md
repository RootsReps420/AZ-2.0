# environments/prd/connectivity

Connectivity subscription root for **prd**.

Composition:

| Hub | Module | Role | Default prefix |
|---|---|---|---|
| Hub01 | `hub-secured` | AZFW + Routing Intent + ExpressRoute | `10.218.64.0/22` |
| Hub02 | `hub-unsecured` | VPN gateway shell (MSH path) | `10.218.68.0/22` |
| Hub03 | `hub-spare` | Bare spare (vWAN mesh only; no spokes) | `10.218.72.0/22` |

Plus baseline firewall policy (DNS proxy on; rule collections stub).

**int** remains two-hub (`10.170.245/246`) until INT Azure 2.0 ranges arrive — see `docs/address-plan-hubs.md`.

```bash
terraform init -backend=false
terraform validate
```
