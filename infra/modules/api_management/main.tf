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
# ------------------------------------------------------------------------------------------------------
# Deploy log analytics workspace
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
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }
  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.api_management_subnet_id
  }
}

resource "azurerm_api_management_api" "openai_api" {
  name                = "AzureOpenAI"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api_management.name
  revision            = "1"
  display_name        = "Azure OpenAI"
  path                = "openai"
  protocols           = ["https"]
  import {
    content_format = "openapi-link"
    content_value  = var.openai_openapi_specification_url
  }
  subscription_required = true
  api_type              = "http"
}

resource "azurerm_api_management_api_policy" "openai_api_policy" {
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  api_name            = azurerm_api_management_api.openai_api.name
  xml_content         = file("${path.module}/policies/openai.xml")
}

resource "azurerm_api_management_named_value" "openai_backend" {
  api_management_name = azurerm_api_management.api_management.name
  name                = "openai-backend"
  resource_group_name = var.resource_group_name
  display_name        = "openai-backend"
  value               = "${var.openai_endpoint}openai/"
  secret              = false
}

resource "azurerm_api_management_named_value" "openai_token_limit_per_minute" {
  api_management_name = azurerm_api_management.api_management.name
  name                = "openai-token-limit-per-minute"
  resource_group_name = var.resource_group_name
  display_name        = "openai-token-limit-per-minute"
  value               = var.openai_token_limit_per_minute
  secret              = false
}

resource "azurerm_api_management_named_value" "openai_key" {
  api_management_name = azurerm_api_management.api_management.name
  name                = "openai-key"
  resource_group_name = var.resource_group_name
  display_name        = "openai-key"
  secret              = true
  value_from_key_vault {
    identity_client_id = var.user_assigned_identity_client_id
    secret_id          = var.openai_key_keyvault_secret_id
  }
}

resource "azurerm_api_management_backend" "openai_backend" {
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  name                = "openai-backend"
  url                 = azurerm_api_management_named_value.openai_backend.value
  protocol            = "http"
  title               = "OpenAI Backend"
}

resource "azurerm_api_management_policy_fragment" "openai_cosmos_logging_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "openai-cosmos-logging"
  value             = file("${path.module}/policies/openai-cosmos-logging.xml")
  format            = "rawxml"
}

resource "azurerm_api_management_logger" "application_insights_logging" {
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  name                = "application-insights-logger"
  resource_id         = var.application_insights_id
  application_insights {
    instrumentation_key = var.application_insights_instrumentation_key
  }
}

resource "azurerm_api_management_product" "openai_product" {
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  approval_required = true
  display_name = "Azure OpenAI Product"
  product_id = "openai-product"
  published = true
}