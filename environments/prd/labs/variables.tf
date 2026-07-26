variable "azure_subscription_id" {
  description = "Lab subscription GUID for prd (or primary lab sub — split later if multi-lab)."
  type        = string
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "environment" {
  type    = string
  default = "prd"
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
  type    = list(string)
  default = ["10.19.96.1", "10.19.97.1"]
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

# VERIFIED from legacy platform params/prd/config.yml — pers labs (VNet == AVD subnet)
variable "pers_spokes" {
  description = "PERS lab spokes keyed by lab id (01a, 01b, …)."
  type = map(object({
    address_space = list(string)
    avd_subnet    = list(string)
  }))
  default = {
    "01a" = { address_space = ["10.170.160.0/21"], avd_subnet = ["10.170.160.0/21"] }
    "01b" = { address_space = ["10.170.168.0/21"], avd_subnet = ["10.170.168.0/21"] }
    "01c" = { address_space = ["10.170.176.0/21"], avd_subnet = ["10.170.176.0/21"] }
    "01d" = { address_space = ["10.170.184.0/21"], avd_subnet = ["10.170.184.0/21"] }
    "01e" = { address_space = ["10.170.192.0/21"], avd_subnet = ["10.170.192.0/21"] }
    "01f" = { address_space = ["10.170.200.0/21"], avd_subnet = ["10.170.200.0/21"] }
    "01g" = { address_space = ["10.170.208.0/21"], avd_subnet = ["10.170.208.0/21"] }
    "01h" = { address_space = ["10.170.216.0/21"], avd_subnet = ["10.170.216.0/21"] }
    "01i" = { address_space = ["10.170.224.0/22"], avd_subnet = ["10.170.224.0/22"] } # Robotics
    "01j" = { address_space = ["10.170.241.0/27"], avd_subnet = ["10.170.241.0/27"] } # P&D
    "01k" = { address_space = ["10.170.232.0/21"], avd_subnet = ["10.170.232.0/21"] }
    "01l" = { address_space = ["10.170.248.0/21"], avd_subnet = ["10.170.248.0/21"] }
  }
}

# VERIFIED from legacy pers params/prd/config.yml — MSH BU subnets
variable "msh_spokes" {
  description = "MSH lab spokes keyed by lab id (01a/01b)."
  type = map(object({
    address_space = list(string)
    avd_subnets   = map(string) # name => CIDR
  }))
  default = {
    "01a" = {
      address_space = ["10.218.16.0/21"]
      avd_subnets = {
        "AVDSubnet-001" = "10.218.16.0/24"
        "AVDSubnet-002" = "10.218.17.0/24"
        "AVDSubnet-003" = "10.218.18.0/24"
        "AVDSubnet-004" = "10.218.19.0/24"
        "AVDSubnet-008" = "10.218.20.0/26"
        "AVDSubnet-009" = "10.218.21.0/24"
      }
    }
    "01b" = {
      address_space = ["10.218.24.0/21"]
      avd_subnets = {
        "AVDSubnet-005" = "10.218.24.0/22"
        "AVDSubnet-006" = "10.218.28.0/24"
        "AVDSubnet-007" = "10.218.29.0/24"
        "AVDSubnet-999" = "10.218.31.0/24"
      }
    }
  }
}
