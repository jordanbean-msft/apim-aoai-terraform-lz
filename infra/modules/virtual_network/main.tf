terraform {
  required_providers {
    azurerm = {
      version = "~>3.116.0"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.28"
    }
  }
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = each.value.service_delegation == true ? [1] : []

    content {
      name = "delegation"
      service_delegation {
        name    = each.value.delegation_name
        actions = each.value.actions
      }
    }
  }
}

module "network_security_group" {
  for_each               = { for subnet in var.subnets : subnet.name => subnet }
  source                 = "../network_security_group"
  resource_group_name    = var.resource_group_name
  tags                   = var.tags
  resource_token         = var.resource_token
  location               = var.location
  network_security_rules = each.value.network_security_rules
  subnet_id              = azurerm_subnet.subnet[each.key].id
  subnet_name            = each.key
  depends_on             = [azurerm_subnet.subnet]
}