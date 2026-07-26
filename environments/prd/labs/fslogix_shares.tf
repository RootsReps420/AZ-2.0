# FSLogix file share quotas — PRD mirrors legacy hostpool JSON quotas exactly.
# Source: legacy/mult/vdi-mult/params/hostpools/*.json (fileShareQuota).
# Placement onto per-BU STAs is in fslogix_stas.tf.
# 005-01 = 51200 GB is intentional.

locals {
  fslogix_profile_pools = [
    "001-00", "001-01", "001-02",
    "002-00", "002-01", "002-02",
    "003-00", "003-01", "003-02",
    "004-00", "004-01", "004-02",
    "005-00", "005-01", "005-02",
    "006-00", "006-01", "006-02",
    "007-00", "007-01", "007-02",
    "008-00", "008-01", "008-02",
    "009-00", "009-01", "009-02",
    "999-00", "999-01", "999-02",
  ]

  fslogix_redirection_quota_gb = 100

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

  fslogix_share_quotas = {
    for pool, gb in local.fslogix_profile_quotas : pool => { quota_gb = gb }
  }
}
