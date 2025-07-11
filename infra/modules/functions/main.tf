# ------------------------------------------------------------------------------------------------------
# Deploy Azure Function
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "service_plan_name" {
  name          = var.resource_token
  resource_type = "azurerm_app_service_plan"
  random_length = 0
  clean_input   = true
}

resource "azurerm_service_plan" "service_plan" {
  name                   = azurecaf_name.service_plan_name.result
  location               = var.location
  resource_group_name    = var.resource_group_name
  os_type                = "Linux"
  sku_name               = var.sku_name
  tags                   = var.tags
  zone_balancing_enabled = var.zone_balancing_enabled
}

resource "azurecaf_name" "function_name" {
  name          = var.resource_token
  resource_type = "azurerm_function_app"
  random_length = 0
  clean_input   = true
}

resource "azurerm_function_app_flex_consumption" "function_app" {
  name                = azurecaf_name.function_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, { "azd-service-name" = "write-to-cosmos" })
  service_plan_id     = azurerm_service_plan.service_plan.id
  https_only          = true
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
  virtual_network_subnet_id         = var.vnet_function_subnet_id
  storage_container_type            = "blobContainer"
  storage_container_endpoint        = "https://${var.storage_account_name}.blob.core.windows.net/${var.storage_account_container_name}"
  storage_authentication_type       = "UserAssignedIdentity"
  storage_user_assigned_identity_id = var.managed_identity_id
  public_network_access_enabled     = false
  runtime_name                      = "python"
  runtime_version                   = "3.11"
  site_config {
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key               = var.application_insights_key
    ip_restriction_default_action          = "Deny"
  }
  app_settings                                   = var.app_settings
  webdeploy_publish_basic_authentication_enabled = false
}

module "private_endpoint" {
  source                         = "../private_endpoint"
  name                           = azurerm_function_app_flex_consumption.function_app.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_function_app_flex_consumption.function_app.id
  location                       = var.location
  subnet_id                      = var.private_endpoint_subnet_id
  subresource_names              = ["sites"]
  is_manual_connection           = false
}

resource "azurerm_monitor_diagnostic_setting" "function_logging" {
  name                       = "function-logging"
  target_resource_id         = azurerm_function_app_flex_consumption.function_app.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category_group = "audit"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
