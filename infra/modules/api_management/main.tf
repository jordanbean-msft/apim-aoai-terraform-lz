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

# module "api_management" {
#   source              = "Azure/avm-res-apimanagement-service/azurerm"
#   version             = "0.0.4"
#   name                = azurecaf_name.api_management_name.result
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   publisher_email     = var.publisher_email
#   publisher_name      = var.publisher_name
#   sku_name            = "${var.sku_name}_${var.sku_capacity}"
#   tags                = var.tags
#   # diagnostic_settings = {
#   #   default = {
#   #     workspace_resource_id = var.log_analytics_workspace_id
#   #   }
#   # }
#   managed_identities = {
#     user_assigned_identity_id = [var.user_assigned_identity_id]
#   }
#   private_endpoints = {
#     api_management_private_endpoint = {
#       subnet_resource_id = var.private_endpoint_subnet_id
#     }
#   }
#   public_network_access_enabled = false
#   #virtual_network_subnet_id     = var.api_management_subnet_id
#   #virtual_network_type          = "None"
#   # zones                         = var.zones
# }

resource "azurerm_api_management" "api_management" {
  name                = azurecaf_name.api_management_name.result
  location            = var.location
  tags                = var.tags
  resource_group_name = var.resource_group_name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = "${var.sku_name}_${var.sku_capacity}"
  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }
  virtual_network_type = "External"
  virtual_network_configuration {
    subnet_id = var.api_management_subnet_id
  }
  zones                         = var.zones
  public_network_access_enabled = true // temporary because you cannot disable public network access on a new APIM instance, it will be updated later to be disabled

  lifecycle {
    ignore_changes = [
      public_network_access_enabled
    ]
  }
}

# data "azurerm_resource_group" "resource_group" {
#   name = var.resource_group_name
# }

# # resource "azurerm_role_assignment" "api_management_system_assigned_managed_identity_cognitive_services_openai_user" {
# #   scope                = data.azurerm_resource_group.resource_group.id
# #   role_definition_name = "Cognitive Services OpenAI User"
# #   principal_id         = azurerm_api_management.api_management.identity.*.principal_id[0]
# # }

resource "azurerm_monitor_diagnostic_setting" "apim_logging" {
  name                       = "apim-logging"
  target_resource_id         = azurerm_api_management.api_management.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

module "private_endpoint" {
  source                         = "../private_endpoint"
  name                           = azurerm_api_management.api_management.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_api_management.api_management.id
  location                       = var.location
  subnet_id                      = var.private_endpoint_subnet_id
  subresource_names              = ["Gateway"]
}

resource "azapi_update_resource" "update_api_management" {
  type        = "Microsoft.ApiManagement/service@2024-06-01-preview"
  resource_id = azurerm_api_management.api_management.id
  depends_on  = [module.private_endpoint]
  body = {
    properties = {
      publicNetworkAccess = "Disabled"
      # virtualNetworkConfiguration = {
      #   subnetResourceId = var.api_management_subnet_id
      # }
      # virtualNetworkType = "External"
    }
  }
}
