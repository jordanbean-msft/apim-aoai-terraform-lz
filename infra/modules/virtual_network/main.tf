data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "apim_subnet" {
  name                 = var.api_management_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

resource "azapi_update_resource" "apim_service_endpoint_delegation" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2024-03-01"
  resource_id = data.azurerm_subnet.apim_subnet.id

  body = {
    properties = {
      delegations = [
        {
          name = "Microsoft.Web/serverFarms"
          properties = {
            serviceName = "Microsoft.Web/serverFarms"
          }
        }
      ]
    }
  }
}

data "azurerm_subnet" "ai_foundry_agents_subnet" {
  name                 = var.ai_foundry_agents_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

resource "azapi_update_resource" "ai_foundry_agent_service_endpoint_delegation" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2024-03-01"
  resource_id = data.azurerm_subnet.function_app_subnet.id

  body = {
    properties = {
      delegations = [
        {
          name = "Microsoft.App/environments"
          properties = {
            serviceName = "Microsoft.App/environments"
          }
        }
      ]
    }
  }
}

data "azurerm_subnet" "function_app_subnet" {
  name                 = var.function_app_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

resource "azapi_update_resource" "function_app_service_endpoint_delegation" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2024-03-01"
  resource_id = data.azurerm_subnet.function_app_subnet.id

  body = {
    properties = {
      delegations = [
        {
          name = "Microsoft.Web/serverFarms"
          properties = {
            serviceName = "Microsoft.Web/serverFarms"
          }
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
