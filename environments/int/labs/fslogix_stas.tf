# FSLogix storage accounts — legacy p_FSLogixSta (01a ×6 + 01b ×4).
# Names match legacy: uks{env}vdimultilb{lab}pf{bu} (24 chars).
# Share quotas: fslogix_shares.tf (INT RTL 100 GB).

locals {
  fslogix_aadkerb = {
    domain_name = "IAGLOBAL.lloydstsb.com"
    domain_guid = "f70769ba-cdf7-4a8e-ae90-d34f58bb4287"
  }

  # lab + bu → STA key
  fslogix_stas = {
    "01a-001" = { lab = "01a", bu = "001", avd_subnet = "AVDSubnet-001" }
    "01a-002" = { lab = "01a", bu = "002", avd_subnet = "AVDSubnet-002" }
    "01a-003" = { lab = "01a", bu = "003", avd_subnet = "AVDSubnet-003" }
    "01a-004" = { lab = "01a", bu = "004", avd_subnet = "AVDSubnet-004" }
    "01a-008" = { lab = "01a", bu = "008", avd_subnet = "AVDSubnet-008" }
    "01a-009" = { lab = "01a", bu = "009", avd_subnet = "AVDSubnet-009" }
    "01b-005" = { lab = "01b", bu = "005", avd_subnet = "AVDSubnet-005" }
    "01b-006" = { lab = "01b", bu = "006", avd_subnet = "AVDSubnet-006" }
    "01b-007" = { lab = "01b", bu = "007", avd_subnet = "AVDSubnet-007" }
    "01b-999" = { lab = "01b", bu = "999", avd_subnet = "AVDSubnet-999" }
  }

  fslogix_legacy_sta_name = {
    for k, v in local.fslogix_stas :
    k => "uks${local.env}vdimultilb${v.lab}pf${v.bu}"
  }

  # Pool → STA key (bu from first 3 chars of pool id)
  fslogix_pool_sta_key = {
    for pool in local.fslogix_profile_pools :
    pool => one([
      for k, v in local.fslogix_stas : k if v.bu == substr(pool, 0, 3)
    ])
  }

  fslogix_shares_by_sta = {
    for sta_key, _ in local.fslogix_stas : sta_key => merge(
      {
        for pool in local.fslogix_profile_pools :
        "profiles-${pool}" => local.fslogix_share_quotas[pool]
        if local.fslogix_pool_sta_key[pool] == sta_key
      },
      { "redirection" = { quota_gb = local.fslogix_redirection_quota_gb } }
    )
  }
}
