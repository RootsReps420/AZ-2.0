# FSLogix file share quotas — INT is RTL (reduced test lab): all profile shares 100 GB.
# Share names match legacy Mult_DeployAVD profiles-{bu}-{pool}; redirection 100 GB.
# Placement onto per-BU STAs is in fslogix_stas.tf.

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

  fslogix_share_quotas = {
    for pool in local.fslogix_profile_pools : pool => { quota_gb = 100 }
  }
}
