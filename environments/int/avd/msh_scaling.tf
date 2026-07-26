# MSH shared schedule catalog â€” ported from legacy/mult/vdi-mult/params/scalingPlanSchedules.json
# Times are HH:MM strings for modules/avd/scalingplan pooled_schedules.

locals {
  msh_schedule_catalog = {
    standard_weekdays_schedule = {
      days_of_week                             = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
      ramp_up_start_time                       = "05:00"
      ramp_up_load_balancing_algorithm         = "BreadthFirst"
      ramp_up_minimum_hosts_percent            = 30
      ramp_up_capacity_threshold_percent       = 60
      peak_start_time                          = "11:00"
      peak_load_balancing_algorithm            = "DepthFirst"
      ramp_down_start_time                     = "18:00"
      ramp_down_load_balancing_algorithm       = "DepthFirst"
      ramp_down_minimum_hosts_percent          = 10
      ramp_down_capacity_threshold_percent     = 90
      ramp_down_force_logoff_users             = false
      ramp_down_wait_time_minutes              = 90
      ramp_down_notification_message           = ""
      ramp_down_stop_hosts_when                = "ZeroSessions"
      off_peak_start_time                      = "22:00"
      off_peak_load_balancing_algorithm        = "BreadthFirst"
    }
    standard_weekend_schedule = {
      days_of_week                             = ["Saturday", "Sunday"]
      ramp_up_start_time                       = "07:00"
      ramp_up_load_balancing_algorithm         = "BreadthFirst"
      ramp_up_minimum_hosts_percent            = 10
      ramp_up_capacity_threshold_percent       = 70
      peak_start_time                          = "09:00"
      peak_load_balancing_algorithm            = "DepthFirst"
      ramp_down_start_time                     = "18:00"
      ramp_down_load_balancing_algorithm       = "DepthFirst"
      ramp_down_minimum_hosts_percent          = 5
      ramp_down_capacity_threshold_percent     = 90
      ramp_down_force_logoff_users             = false
      ramp_down_wait_time_minutes              = 90
      ramp_down_notification_message           = ""
      ramp_down_stop_hosts_when                = "ZeroSessions"
      off_peak_start_time                      = "22:00"
      off_peak_load_balancing_algorithm        = "BreadthFirst"
    }
    # BU 005 (Consumer Relationships) â€” later ramp-down, higher weekday min hosts
    standard_weekdays_schedule_005 = {
      days_of_week                             = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
      ramp_up_start_time                       = "05:00"
      ramp_up_load_balancing_algorithm         = "BreadthFirst"
      ramp_up_minimum_hosts_percent            = 60
      ramp_up_capacity_threshold_percent       = 60
      peak_start_time                          = "11:00"
      peak_load_balancing_algorithm            = "DepthFirst"
      ramp_down_start_time                     = "20:30"
      ramp_down_load_balancing_algorithm       = "DepthFirst"
      ramp_down_minimum_hosts_percent          = 10
      ramp_down_capacity_threshold_percent     = 90
      ramp_down_force_logoff_users             = false
      ramp_down_wait_time_minutes              = 90
      ramp_down_notification_message           = ""
      ramp_down_stop_hosts_when                = "ZeroSessions"
      off_peak_start_time                      = "22:00"
      off_peak_load_balancing_algorithm        = "BreadthFirst"
    }
    standard_weekdays_schedule_canary = {
      days_of_week                             = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
      ramp_up_start_time                       = "05:00"
      ramp_up_load_balancing_algorithm         = "DepthFirst"
      ramp_up_minimum_hosts_percent            = 10
      ramp_up_capacity_threshold_percent       = 80
      peak_start_time                          = "11:00"
      peak_load_balancing_algorithm            = "DepthFirst"
      ramp_down_start_time                     = "18:00"
      ramp_down_load_balancing_algorithm       = "DepthFirst"
      ramp_down_minimum_hosts_percent          = 10
      ramp_down_capacity_threshold_percent     = 90
      ramp_down_force_logoff_users             = false
      ramp_down_wait_time_minutes              = 90
      ramp_down_notification_message           = ""
      ramp_down_stop_hosts_when                = "ZeroSessions"
      off_peak_start_time                      = "22:00"
      off_peak_load_balancing_algorithm        = "BreadthFirst"
    }
    standard_weekdays_schedule_005_canary = {
      days_of_week                             = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
      ramp_up_start_time                       = "05:00"
      ramp_up_load_balancing_algorithm         = "DepthFirst"
      ramp_up_minimum_hosts_percent            = 10
      ramp_up_capacity_threshold_percent       = 80
      peak_start_time                          = "11:00"
      peak_load_balancing_algorithm            = "DepthFirst"
      ramp_down_start_time                     = "20:30"
      ramp_down_load_balancing_algorithm       = "DepthFirst"
      ramp_down_minimum_hosts_percent          = 10
      ramp_down_capacity_threshold_percent     = 90
      ramp_down_force_logoff_users             = false
      ramp_down_wait_time_minutes              = 90
      ramp_down_notification_message           = ""
      ramp_down_stop_hosts_when                = "ZeroSessions"
      off_peak_start_time                      = "22:00"
      off_peak_load_balancing_algorithm        = "BreadthFirst"
    }
  }

  # Per host pool — from legacy hostpools/*.json + RDPProperties.json (30 pools)
  msh_host_pools = {
    "001-00" = {
      schedule_keys              = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = true
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Tusker (001-00)"
      business_unit_name        = "Tusker"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "001-01" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 10
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Tusker (001-01)"
      business_unit_name        = "Tusker"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "001-02" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Tusker (001-02)"
      business_unit_name        = "Tusker"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "002-00" = {
      schedule_keys              = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = true
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Corporate & Institutional Banking (002-00)"
      business_unit_name        = "Corporate & Institutional Banking"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "002-01" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Corporate & Institutional Banking (002-01)"
      business_unit_name        = "Corporate & Institutional Banking"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "002-02" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Corporate & Institutional Banking (002-02)"
      business_unit_name        = "Corporate & Institutional Banking"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "003-00" = {
      schedule_keys              = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = true
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Insurance, Pensions & Investments (003-00)"
      business_unit_name        = "Insurance, Pensions & Investments"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "003-01" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 18
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Insurance, Pensions & Investments (003-01)"
      business_unit_name        = "Insurance, Pensions & Investments"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "003-02" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 15
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Insurance, Pensions & Investments (003-02)"
      business_unit_name        = "Insurance, Pensions & Investments"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "004-00" = {
      schedule_keys              = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = true
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "GCOO (004-00)"
      business_unit_name        = "GCOO"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "004-01" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "GCOO (004-01)"
      business_unit_name        = "GCOO"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "004-02" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = false
      description               = "Associated Risk Numbers: RK0029382"
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:*;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "GCOO (004-02)"
      business_unit_name        = "GCOO"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "005-00" = {
      schedule_keys              = ["standard_weekdays_schedule_005_canary", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Consumer Relationships (005-00)"
      business_unit_name        = "Consumer Relationships"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "005-01" = {
      schedule_keys              = ["standard_weekdays_schedule_005", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 18
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Consumer Relationships (005-01)"
      business_unit_name        = "Consumer Relationships"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "005-02" = {
      schedule_keys              = ["standard_weekdays_schedule_005", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 15
      validate_environment      = false
      description               = "Associated Risk Numbers: CFA risk R047172"
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Consumer Relationships (005-02)"
      business_unit_name        = "Consumer Relationships"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "006-00" = {
      schedule_keys              = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = true
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Consumer Lending (006-00)"
      business_unit_name        = "Consumer Lending"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "006-01" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 18
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Consumer Lending (006-01)"
      business_unit_name        = "Consumer Lending"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "006-02" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = false
      description               = "Associated Risk Numbers: RO51812 - (being registered SNC with associated risk under RO51812, logged in RCSA)"
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Consumer Lending (006-02)"
      business_unit_name        = "Consumer Lending"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "007-00" = {
      schedule_keys              = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = true
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Cavendish Online (007-00)"
      business_unit_name        = "Cavendish Online"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "007-01" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 15
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Cavendish Online (007-01)"
      business_unit_name        = "Cavendish Online"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "007-02" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = false
      description               = "Associated Risk Numbers: Local register CAV003"
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Cavendish Online (007-02)"
      business_unit_name        = "Cavendish Online"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "008-00" = {
      schedule_keys              = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = true
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Group Functions (008-00)"
      business_unit_name        = "Group Functions"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "008-01" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 15
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Group Functions (008-01)"
      business_unit_name        = "Group Functions"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "008-02" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 15
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Group Functions (008-02)"
      business_unit_name        = "Group Functions"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "009-00" = {
      schedule_keys              = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = true
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Connect Core (009-00)"
      business_unit_name        = "Connect Core"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "009-01" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 18
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Connect Core (009-01)"
      business_unit_name        = "Connect Core"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "009-02" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 18
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Connect Core (009-02)"
      business_unit_name        = "Connect Core"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "999-00" = {
      schedule_keys              = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 6
      validate_environment      = true
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:0;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Administration (999-00)"
      business_unit_name        = "Administration"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "999-01" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 15
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;enablerdsaadauth:i:1;"
      app_group_friendly_name   = "Administration (999-01)"
      business_unit_name        = "Administration"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
    "999-02" = {
      schedule_keys              = ["standard_weekdays_schedule", "standard_weekend_schedule"]
      maximum_sessions_allowed  = 15
      validate_environment      = false
      description               = "Associated Risk Numbers: "
      custom_rdp_properties     = "enablecredsspsupport:i:1;camerastoredirect:s:*;redirectclipboard:i:1;redirectprinters:i:1;redirectsmartcards:i:0;smart sizing:i:1;audiomode:i:0;audiocapturemode:i:1;drivestoredirect:s:*;videoplaybackmode:i:1;devicestoredirect:s:;usbdevicestoredirect:s:;use multimon:i:0;redirectcomports:i:0;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;screen mode id:i:2;dynamic resolution:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;"
      app_group_friendly_name   = "Administration (999-02)"
      business_unit_name        = "Administration"
      # agentUpdate: Scheduled Sat 01:00 GMT Standard Time (all 30)
    }
  }

  # From scalingPlanSchedulesDecom.json
  msh_decom_schedule = {
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    ramp_up_start_time                   = "05:00"
    ramp_up_load_balancing_algorithm     = "DepthFirst"
    ramp_up_minimum_hosts_percent        = 0
    ramp_up_capacity_threshold_percent   = 60
    peak_start_time                      = "06:00"
    peak_load_balancing_algorithm        = "DepthFirst"
    ramp_down_start_time                 = "22:30"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 0
    ramp_down_capacity_threshold_percent = 90
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 90
    ramp_down_notification_message       = ""
    ramp_down_stop_hosts_when            = "ZeroSessions"
    off_peak_start_time                  = "23:59"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }
}
