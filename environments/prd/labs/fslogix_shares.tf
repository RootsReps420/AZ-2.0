# FSLogix file shares — PRD mirrors legacy hostpool JSON quotas exactly.
# Source: legacy/mult/vdi-mult/params/hostpools/*.json (fileShareQuota).
# Share names: profiles-{bu}-{pool}; redirection 100 GB (legacy env override).
# 005-01 = 51200 GB is intentional.

locals {
  fslogix_profile_quotas = {
    "001-00" = 100
    "001-01" = 2500
    "001-02" = 100
    "002-00" = 100
    "002-01" = 100
    "002-02" = 100
    "003-00" = 150
    "003-01" = 5120
    "003-02" = 100
    "004-00" = 100
    "004-01" = 600
    "004-02" = 1400
    "005-00" = 300
    "005-01" = 51200
    "005-02" = 1500
    "006-00" = 100
    "006-01" = 3700
    "006-02" = 500
    "007-00" = 100
    "007-01" = 350
    "007-02" = 100
    "008-00" = 150
    "008-01" = 200
    "008-02" = 600
    "009-00" = 700
    "009-01" = 1100
    "009-02" = 5120
    "999-00" = 100
    "999-01" = 100
    "999-02" = 100
  }

  fslogix_shares = merge(
    { for pool, gb in local.fslogix_profile_quotas : "profiles-${pool}" => { quota_gb = gb } },
    { "redirection" = { quota_gb = 100 } },
  )
}
