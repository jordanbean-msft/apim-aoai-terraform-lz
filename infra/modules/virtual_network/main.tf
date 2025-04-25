terraform {
  required_providers {
    azurerm = {
      version = "~>4.0.1"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.28"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.3.0"
    }
  }
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

# resource "azurerm_subnet" "subnet" {
#   for_each = { for subnet in var.subnets : subnet.name => subnet }

#   name                 = each.key
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = data.azurerm_virtual_network.vnet.name
#   address_prefixes     = each.value.address_prefixes

#   dynamic "delegation" {
#     for_each = each.value.service_delegation == true ? [1] : []

#     content {
#       name = "delegation"
#       service_delegation {
#         name    = each.value.delegation_name
#         actions = each.value.actions
#       }
#     }
#   }
# }

data "azurerm_subnet" "integration_subnet" {
  name                 = var.function_app_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

resource "azapi_update_resource" "service_endpoint_delegation" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2024-03-01"
  resource_id = data.azurerm_subnet.integration_subnet.id

  body = {
    properties = {
      delegations = [
        {
          name = "Microsoft.Web/serverFarms"
        }
      ]
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
  subnet_id              = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.virtual_network_name}/subnets/${each.key}"
  subnet_name            = each.key
}

# module "route_table" {
#   for_each            = { for subnet in var.subnets : subnet.name => subnet if length(keys(subnet.route_table)) > 0 }
#   source              = "../route_table"
#   name                = each.value.route_table.name
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
#   resource_token      = var.resource_token
#   location            = var.location
#   routes              = each.value.route_table.routes
# }

# resource "azurecaf_name" "route_table_name" {
#   name          = "$apim-${var.resource_token}"
#   resource_type = "azurerm_route_table"
#   random_length = 0
#   clean_input   = true
# }

# resource "azurerm_route_table" "route_table" {
#   name                = azurecaf_name.route_table_name.result
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
# }

# resource "azurerm_route" "apim_control_plane" {
#   name                = "ApimControlPlane"
#   resource_group_name = var.resource_group_name
#   route_table_name    = azurerm_route_table.route_table.name
#   address_prefix      = "ApiManagement"
#   next_hop_type       = "Internet"
# }

# resource "azurerm_route" "internet_to_firewall" {
#   name                   = "InternetToFirewall"
#   resource_group_name    = var.resource_group_name
#   route_table_name       = azurerm_route_table.route_table.name
#   address_prefix         = "0.0.0.0/0"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = var.firewall_ip_address
# }

# data "azurerm_subnet" "apim_subnet" {
#   name                 = var.api_management_subnet_name
#   virtual_network_name = var.virtual_network_name
#   resource_group_name  = var.resource_group_name
# }

# resource "azurerm_subnet_route_table_association" "subnet_route_table_association" {
#   subnet_id      = data.azurerm_subnet.apim_subnet.id
#   route_table_id = azurerm_route_table.route_table.id
# }
