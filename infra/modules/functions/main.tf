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

resource "azurerm_linux_function_app" "function_app" {
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
  key_vault_reference_identity_id = var.managed_identity_id
  storage_account_access_key      = var.storage_account_access_key
  virtual_network_subnet_id       = var.vnet_function_subnet_id
  storage_account_name            = var.storage_account_name
  public_network_access_enabled   = false
  site_config {
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key               = var.application_insights_key
    application_stack {
      python_version = 3.11
    }
    ip_restriction_default_action    = "Deny"
    runtime_scale_monitoring_enabled = true
    ftps_state                       = "FtpsOnly"
  }
  app_settings = var.app_settings
}

module "private_endpoint" {
  source                         = "../private_endpoint"
  name                           = azurerm_linux_function_app.function_app.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_linux_function_app.function_app.id
  location                       = var.location
  subnet_id                      = var.private_endpoint_subnet_id
  subresource_names              = ["sites"]
  is_manual_connection           = false
}