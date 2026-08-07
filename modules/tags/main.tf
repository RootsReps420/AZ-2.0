# ---------------------------------------------------------------------------
# Tags — sole source of Azure resource tags for this repo
#
# Pure computation (no Azure resources). Builds the mandatory tag map every
# stack passes to resources. Single place to change keys / workload strings.
#
# Callers pass a workload *lane* (platform|pers|mult|priv); this module maps
# that to the Azure `workload` tag value (vdi-*).
# ---------------------------------------------------------------------------

locals {
  workload_values = {
    platform = "vdi-platform"
    pers     = "vdi-pers"
    mult     = "vdi-mult"
    priv     = "vdi-priv"
  }

  platform_tags = {
    "managed-by" = "terraform"
    environment  = var.environment
    region       = var.region
    workload     = local.workload_values[var.workload]
    repo         = "vdi-terraform"
  }

  # Platform keys win if they ever collide with bank mandatory keys.
  tags = merge(var.mandatory, local.platform_tags)
}
