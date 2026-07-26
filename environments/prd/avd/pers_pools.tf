# PERS personal host-pool catalog — from legacy scripts PERS-General_* + PERS-Packaging_*
# (PRIV / Robot out of scope). Same pool IDs for int and prd.

locals {
  # RDP strings from legacy scripts/params/RDPProperties.json (PS join name:value)
  pers_rdp = {
    standard          = "targetisaadjoined:i: 1;enablecredsspsupport:i: 1;camerastoredirect:s:*;redirectclipboard:i: 0;redirectprinters:i: 0;redirectsmartcards:i: 0;singlemoninwindowedmode:i: 1;smart sizing:i: 1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:1;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;selectedmonitors:s:;maximizetocurrentdisplays:i:0;screen mode id:i:2;dynamic resolution:i:1"
    copypaste         = "targetisaadjoined:i: 1;enablecredsspsupport:i: 1;camerastoredirect:s:*;redirectclipboard:i: 1;redirectprinters:i: 0;redirectsmartcards:i: 0;singlemoninwindowedmode:i: 1;smart sizing:i: 1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:1;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;selectedmonitors:s:;maximizetocurrentdisplays:i:0;screen mode id:i:2;dynamic resolution:i:1"
    smartcard         = "targetisaadjoined:i: 1;enablecredsspsupport:i: 1;camerastoredirect:s:*;redirectclipboard:i: 0;redirectprinters:i: 0;redirectsmartcards:i: 1;singlemoninwindowedmode:i: 1;smart sizing:i: 1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:1;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;selectedmonitors:s:;maximizetocurrentdisplays:i:0;screen mode id:i:2;dynamic resolution:i:1"
    "print-copypaste" = "targetisaadjoined:i: 1;enablecredsspsupport:i: 1;camerastoredirect:s:*;redirectclipboard:i: 1;redirectprinters:i: 1;redirectsmartcards:i: 0;singlemoninwindowedmode:i: 1;smart sizing:i: 1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:1;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;selectedmonitors:s:;maximizetocurrentdisplays:i:0;screen mode id:i:2;dynamic resolution:i:1"
  }

  # Default catalog when var.pers_host_pools is empty — set var to {} explicitly to skip PERS AVD
  pers_host_pools_catalog = {
    "001-01" = { rdp_persona = "standard", description = "PERS-General standard" }
    "001-02" = { rdp_persona = "standard", description = "PERS-General standard" }
    "001-03" = { rdp_persona = "standard", description = "PERS-General standard" }
    "001-04" = { rdp_persona = "copypaste", description = "PERS-General copypaste" }
    "001-05" = { rdp_persona = "smartcard", description = "PERS-General smartcard" }
    "001-06" = { rdp_persona = "smartcard", description = "PERS-General smartcard" }
    "002-01" = { rdp_persona = "print-copypaste", description = "PERS-General print-copypaste" }
    "003-01" = { rdp_persona = "copypaste", description = "PERS-Packaging copypaste" }
    "003-02" = { rdp_persona = "copypaste", description = "PERS-Packaging copypaste" }
    "003-03" = { rdp_persona = "copypaste", description = "PERS-Packaging copypaste" }
  }

  # Empty map in tfvars means "use catalog"; set enable_pers_host_pools = false to skip
  pers_host_pools = var.enable_pers_host_pools ? (
    length(var.pers_host_pools) > 0 ? var.pers_host_pools : local.pers_host_pools_catalog
  ) : {}

  pers_workspace_friendly_name = local.env == "prd" ? "LIVE-DESKTOPS" : "RTL-DESKTOPS"
}
