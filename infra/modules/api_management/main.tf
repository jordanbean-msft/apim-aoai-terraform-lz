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
  }
}
# ------------------------------------------------------------------------------------------------------
# Deploy API Management
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "api_management_name" {
  name          = var.resource_token
  resource_type = "azurerm_api_management"
  random_length = 0
  clean_input   = true
}

resource "azurerm_api_management" "api_management" {
  name                = azurecaf_name.api_management_name.result
  location            = var.location
  tags                = var.tags
  resource_group_name = var.resource_group_name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = var.sku_name
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }
  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.api_management_subnet_id
  }
  zones = var.zones
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_role_assignment" "api_management_system_assigned_managed_identity_cognitive_services_openai_user" {
  scope                = data.azurerm_resource_group.resource_group.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_api_management.api_management.identity.*.principal_id[0]
}

resource "azurerm_monitor_diagnostic_setting" "apim_logging" {
  name                       = "apim-logging"
  target_resource_id         = azurerm_api_management.api_management.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "GatewayLogs"
  }

  metric {
    category = "AllMetrics"
  }
}