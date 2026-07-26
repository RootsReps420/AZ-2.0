# Kept in its own file so the language server always indexes this input
# (complex object types in a large variables.tf have historically been skipped).
variable "scheduled_agent_updates" {
  description = "Optional scheduled AVD agent update window. Legacy MSH: enabled, GMT Standard Time, Saturday 01:00, use_session_host_timezone false."
  type = object({
    enabled                   = bool
    timezone                  = string
    use_session_host_timezone = bool
    schedules = list(object({
      day_of_week = string
      hour_of_day = number
    }))
  })
  default  = null
  nullable = true
}
