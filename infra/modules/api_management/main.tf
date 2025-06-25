# ------------------------------------------------------------------------------------------------------
# Deploy API Management
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "api_management_name" {
  name          = var.resource_token
  resource_type = "azurerm_api_management"
  random_length = 0
  clean_input   = true
}

data "azapi_resource" "resource_group" {
  type = "Microsoft.Resources/resourceGroups@2021-04-01"
  name = var.resource_group_name
}

resource "azapi_resource" "api_management" {
  type      = "Microsoft.ApiManagement/service@2024-06-01-preview"
  name      = azurecaf_name.api_management_name.result
  location  = var.location
  tags      = var.tags
  parent_id = data.azapi_resource.resource_group.id
  body = {
    identity = {
      type = "SystemAssigned,UserAssigned"
      userAssignedIdentities = {
        "${var.user_assigned_identity_id}" = {}
      }
    }
    sku = {
      name     = var.sku_name
      capacity = var.sku_capacity
    }
    zones = var.zones
    properties = {
      publisherEmail = var.publisher_email
      publisherName  = var.publisher_name

      virtualNetworkConfiguration = {
        subnetResourceId = var.api_management_subnet_id
      }
      virtualNetworkType = "Internal"
    }
  }
}
# resource "azurerm_api_management" "api_management" {
#   name                = azurecaf_name.api_management_name.result
#   location            = var.location
#   tags                = var.tags
#   resource_group_name = var.resource_group_name
#   publisher_email     = var.publisher_email
#   publisher_name      = var.publisher_name
#   sku_name            = var.sku_name
#   identity {
#     type         = "SystemAssigned, UserAssigned"
#     identity_ids = [var.user_assigned_identity_id]
#   }
#   virtual_network_type = "External"
#   virtual_network_configuration {
#     subnet_id = var.api_management_subnet_id
#   }
#   zones = var.zones
# }

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# resource "azurerm_role_assignment" "api_management_system_assigned_managed_identity_cognitive_services_openai_user" {
#   scope                = data.azurerm_resource_group.resource_group.id
#   role_definition_name = "Cognitive Services OpenAI User"
#   principal_id         = azapi_resource.api_management.identity.*.principal_id[0]
# }

resource "azurerm_monitor_diagnostic_setting" "apim_logging" {
  name                       = "apim-logging"
  target_resource_id         = azapi_resource.api_management.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "GatewayLogs"
  }

  metric {
    category = "AllMetrics"
  }
}
