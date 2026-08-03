# NSG security_rules — exact legacy shapes from labCorePersistent / labCoreMulti
# params-netsec.json (int + prd). Azure default rules (65000+) are platform-managed.

locals {
  # PERS: scope = that lab's AVDSubnet CIDR (names *-inbound-subnet).
  # Patterns: standard (most), 01i + RPA (no TURN), 01k/01l thin (TCP DO only, no TURN).
  pers_security_rules = {
    for lab, cfg in var.pers_spokes : lab => (
      contains(["01k", "01l"], lab) ? {
        "allow-deliveryoptimization-inbound-subnet" = {
          priority                     = 100
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_range            = "*"
          destination_port_ranges      = ["7680", "3544"]
          source_address_prefixes      = cfg.avd_subnet
          destination_address_prefixes = cfg.avd_subnet
        }
        "deny-subnet-inbound-subnet" = {
          priority                     = 4000
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_range            = "*"
          destination_port_range       = "*"
          source_address_prefixes      = cfg.avd_subnet
          destination_address_prefixes = cfg.avd_subnet
        }
        } : lab == "01i" ? {
        "allow-deliveryoptimization-TCP-inbound-subnet" = {
          priority                     = 100
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_range            = "*"
          destination_port_ranges      = ["7680", "3544"]
          source_address_prefixes      = cfg.avd_subnet
          destination_address_prefixes = cfg.avd_subnet
        }
        "allow-deliveryoptimization-UDP-inbound-subnet" = {
          priority                     = 110
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Udp"
          source_port_range            = "*"
          destination_port_ranges      = ["7680", "3544"]
          source_address_prefixes      = cfg.avd_subnet
          destination_address_prefixes = cfg.avd_subnet
        }
        "allow-subnet-inbound-subnet-rpa" = {
          priority                     = 900
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_range            = "*"
          destination_port_ranges      = ["8181-8183", "8199-8200"]
          source_address_prefixes      = cfg.avd_subnet
          destination_address_prefixes = cfg.avd_subnet
        }
        "deny-subnet-inbound-subnet" = {
          priority                     = 4000
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_range            = "*"
          destination_port_range       = "*"
          source_address_prefixes      = cfg.avd_subnet
          destination_address_prefixes = cfg.avd_subnet
        }
        } : {
        "allow-deliveryoptimization-TCP-inbound-subnet" = {
          priority                     = 100
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_range            = "*"
          destination_port_ranges      = ["7680", "3544"]
          source_address_prefixes      = cfg.avd_subnet
          destination_address_prefixes = cfg.avd_subnet
        }
        "allow-deliveryoptimization-UDP-inbound-subnet" = {
          priority                     = 110
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Udp"
          source_port_range            = "*"
          destination_port_ranges      = ["7680", "3544"]
          source_address_prefixes      = cfg.avd_subnet
          destination_address_prefixes = cfg.avd_subnet
        }
        "deny-subnet-inbound-subnet" = {
          priority                     = 4000
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_range            = "*"
          destination_port_range       = "*"
          source_address_prefixes      = cfg.avd_subnet
          destination_address_prefixes = cfg.avd_subnet
        }
        "deny-subnet-outbound-turn" = {
          priority                     = 100
          direction                    = "Outbound"
          access                       = "Deny"
          protocol                     = "Udp"
          source_port_range            = "*"
          destination_port_range       = "3478"
          source_address_prefixes      = cfg.avd_subnet
          destination_address_prefixes = ["20.202.0.0/16"]
        }
      }
    )
  }

  # PRIV: same shape as standard PERS (DO TCP/UDP + deny east-west + deny TURN)
  priv_security_rules = {
    for lab, cfg in var.priv_spokes : lab => {
      "allow-deliveryoptimization-TCP-inbound-subnet" = {
        priority                     = 100
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_ranges      = ["7680", "3544"]
        source_address_prefixes      = cfg.avd_subnet
        destination_address_prefixes = cfg.avd_subnet
      }
      "allow-deliveryoptimization-UDP-inbound-subnet" = {
        priority                     = 110
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Udp"
        source_port_range            = "*"
        destination_port_ranges      = ["7680", "3544"]
        source_address_prefixes      = cfg.avd_subnet
        destination_address_prefixes = cfg.avd_subnet
      }
      "deny-subnet-inbound-subnet" = {
        priority                     = 4000
        direction                    = "Inbound"
        access                       = "Deny"
        protocol                     = "*"
        source_port_range            = "*"
        destination_port_range       = "*"
        source_address_prefixes      = cfg.avd_subnet
        destination_address_prefixes = cfg.avd_subnet
      }
      "deny-subnet-outbound-turn" = {
        priority                     = 100
        direction                    = "Outbound"
        access                       = "Deny"
        protocol                     = "Udp"
        source_port_range            = "*"
        destination_port_range       = "3478"
        source_address_prefixes      = cfg.avd_subnet
        destination_address_prefixes = ["20.202.0.0/16"]
      }
    }
  }

  # MSH: scope = spoke VNet address_space (names *-inbound-vnet). Same 4 rules on
  # every AVDSubnet NSG in the spoke (legacy labCoreMulti duplicates per subnet).
  msh_security_rules = {
    for lab, cfg in var.msh_spokes : lab => {
      "allow-deliveryoptimization-TCP-inbound-vnet" = {
        priority                     = 100
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_ranges      = ["7680", "3544"]
        source_address_prefixes      = cfg.address_space
        destination_address_prefixes = cfg.address_space
      }
      "allow-deliveryoptimization-UDP-inbound-vnet" = {
        priority                     = 110
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Udp"
        source_port_range            = "*"
        destination_port_ranges      = ["7680", "3544"]
        source_address_prefixes      = cfg.address_space
        destination_address_prefixes = cfg.address_space
      }
      "deny-subnet-inbound-vnet" = {
        priority                     = 4000
        direction                    = "Inbound"
        access                       = "Deny"
        protocol                     = "*"
        source_port_range            = "*"
        destination_port_range       = "*"
        source_address_prefixes      = cfg.address_space
        destination_address_prefixes = cfg.address_space
      }
      "deny-subnet-outbound-turn" = {
        priority                     = 100
        direction                    = "Outbound"
        access                       = "Deny"
        protocol                     = "Udp"
        source_port_range            = "*"
        destination_port_range       = "3478"
        source_address_prefixes      = cfg.address_space
        destination_address_prefixes = ["20.202.0.0/16"]
      }
    }
  }
}
