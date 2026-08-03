variable "azure_subscription_id" {
  description = "Lab subscription GUID for IGMF sandbox (single-sub smoke test)."
  type        = string
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "environment" {
  type    = string
  default = "igmf"
}

variable "subscription_code" {
  type    = string
  default = "vdi"
}

variable "hub01_id" {
  type = string
}

variable "hub02_id" {
  type = string
}

variable "hub01_firewall_private_ip" {
  description = "Hub01 AZFW private IP for PERS default-to-firewall RT and MSH UDR next hop (from connectivity output)."
  type        = string
}

variable "mandatory_tags" {
  type = object({
    costCentre             = string
    securityClassification = string
    resourceOwner          = string
    CMDB_AppID             = string
  })
}

variable "dns_servers" {
  description = "Azure DNS for IGMF — do NOT use bank 10.19.*"
  type        = list(string)
  default     = ["168.63.129.16"]
}

variable "enable_fslogix" {
  type    = bool
  default = true
}

variable "agents_subnet_id" {
  description = "Mgmt AgentsSubnet resource ID for FSLogix/KV network ACLs (legacy allow list). Required for legacy-exact Deny ACL model."
  type        = string
  default     = null
}

variable "law_id" {
  description = "Log Analytics workspace ID for FSLogix file diagnostics (optional until mgmt LAW exists)."
  type        = string
  default     = null
}

variable "enable_lab_keyvaults" {
  description = "Deploy 14 Premium lab Key Vaults (2 Multi + 12 Personal)."
  type        = bool
  default     = true
}

variable "enable_pers_blob" {
  description = "Deploy 12 Personal lab blob storage accounts (StorageV2 Standard_LRS)."
  type        = bool
  default     = true
}

# VERIFIED from legacy pers params/int/config.yml — privileged lab (AVD + reserved FW space)
variable "priv_spokes" {
  description = "Privileged (labCorePriv) spokes. Local AZFW not deployed; Hub01 default-to-firewall."
  type = map(object({
    address_space = list(string)
    avd_subnet    = list(string)
  }))
  default = {
    "01a" = {
      address_space = ["10.170.137.0/24"]
      avd_subnet    = ["10.170.137.0/25"]
    }
  }
}

# VERIFIED from legacy params/int/config.yml — pers labs (VNet == AVD subnet for /28s)
variable "pers_spokes" {
  description = "PERS lab spokes keyed by lab id (01a, 01b, …)."
  type = map(object({
    address_space = list(string)
    avd_subnet    = list(string)
  }))
  default = {
    "01a" = { address_space = ["10.170.140.0/28"], avd_subnet = ["10.170.140.0/28"] }
    "01b" = { address_space = ["10.170.140.16/28"], avd_subnet = ["10.170.140.16/28"] }
    "01c" = { address_space = ["10.170.140.32/28"], avd_subnet = ["10.170.140.32/28"] }
    "01d" = { address_space = ["10.170.140.48/28"], avd_subnet = ["10.170.140.48/28"] }
    "01e" = { address_space = ["10.170.140.64/28"], avd_subnet = ["10.170.140.64/28"] }
    "01f" = { address_space = ["10.170.140.80/28"], avd_subnet = ["10.170.140.80/28"] }
    "01g" = { address_space = ["10.170.140.96/28"], avd_subnet = ["10.170.140.96/28"] }
    "01h" = { address_space = ["10.170.140.112/28"], avd_subnet = ["10.170.140.112/28"] }
    "01i" = { address_space = ["10.170.140.128/28"], avd_subnet = ["10.170.140.128/28"] } # Robotics
    "01j" = { address_space = ["10.170.140.144/28"], avd_subnet = ["10.170.140.144/28"] } # P&D
    "01k" = { address_space = ["10.170.140.160/28"], avd_subnet = ["10.170.140.160/28"] }
    "01l" = { address_space = ["10.170.140.176/28"], avd_subnet = ["10.170.140.176/28"] }
  }
}

# VERIFIED from legacy pers params/int/config.yml — MSH BU subnets
variable "msh_spokes" {
  description = "MSH lab spokes keyed by lab id (01a/01b)."
  type = map(object({
    address_space = list(string)
    avd_subnets   = map(string) # name => CIDR
  }))
  default = {
    "01a" = {
      address_space = ["10.170.141.0/24"]
      avd_subnets = {
        "AVDSubnet-001" = "10.170.141.0/27"
        "AVDSubnet-002" = "10.170.141.32/27"
        "AVDSubnet-003" = "10.170.141.64/27"
        "AVDSubnet-004" = "10.170.141.96/27"
        "AVDSubnet-008" = "10.170.141.128/27"
        "AVDSubnet-009" = "10.170.141.160/27"
      }
    }
    "01b" = {
      address_space = ["10.170.142.0/24"]
      avd_subnets = {
        "AVDSubnet-005" = "10.170.142.0/25"
        "AVDSubnet-006" = "10.170.142.128/27"
        "AVDSubnet-007" = "10.170.142.160/27"
        "AVDSubnet-999" = "10.170.142.192/27"
      }
    }
  }
}
