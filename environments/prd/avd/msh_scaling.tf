# MSH shared schedule catalog — ported from legacy/mult/vdi-mult/params/scalingPlanSchedules.json
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
    # BU 005 (Consumer Relationships) — later ramp-down, higher weekday min hosts
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

  # Per host pool — schedule_keys from legacy hostpools/*.json (30 pools)
  msh_host_pools = {
    "001-00" = { schedule_keys = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"] }
    "001-01" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "001-02" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "002-00" = { schedule_keys = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"] }
    "002-01" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "002-02" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "003-00" = { schedule_keys = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"] }
    "003-01" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "003-02" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "004-00" = { schedule_keys = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"] }
    "004-01" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "004-02" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "005-00" = { schedule_keys = ["standard_weekdays_schedule_005_canary", "standard_weekend_schedule"] } # Consumer Relationships canary
    "005-01" = { schedule_keys = ["standard_weekdays_schedule_005", "standard_weekend_schedule"] }
    "005-02" = { schedule_keys = ["standard_weekdays_schedule_005", "standard_weekend_schedule"] }
    "006-00" = { schedule_keys = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"] }
    "006-01" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "006-02" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "007-00" = { schedule_keys = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"] }
    "007-01" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "007-02" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "008-00" = { schedule_keys = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"] }
    "008-01" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "008-02" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "009-00" = { schedule_keys = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"] }
    "009-01" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "009-02" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "999-00" = { schedule_keys = ["standard_weekdays_schedule_canary", "standard_weekend_schedule"] }
    "999-01" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
    "999-02" = { schedule_keys = ["standard_weekdays_schedule", "standard_weekend_schedule"] }
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
