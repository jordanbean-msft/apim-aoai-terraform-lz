terraform {
  required_providers {
    azurerm = {
      version = "~>3.105.0"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.28"
    }
  }
}
# ------------------------------------------------------------------------------------------------------
# Deploy network security group
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "network_security_group_name" {
  name          = "${var.subnet_name}-${var.resource_token}"
  resource_type = "azurerm_network_security_group"
  random_length = 0
  clean_input   = true
}

resource "azurerm_network_security_group" "network_security_group" {
  name                = azurecaf_name.network_security_group_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "network_security_rule" {
  for_each                    = { for network_security_rule in var.network_security_rules : network_security_rule.name => network_security_rule }
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_ranges     = each.value.destination_port_ranges
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.network_security_group.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_network_security_group_association" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.network_security_group.id
}