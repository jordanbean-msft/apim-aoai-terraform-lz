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

resource "azurerm_api_management_named_value" "cosmosdb_scope" {
  api_management_name = azurerm_api_management.api_management.name
  name                = "cosmosdb-scope"
  resource_group_name = var.resource_group_name
  display_name        = "cosmosdb-scope"
  value               = var.cosmosdb_scope
  secret              = false
}

resource "azurerm_api_management_named_value" "cosmosdb_document_endpoint" {
  api_management_name = azurerm_api_management.api_management.name
  name                = "cosmosdb-document-endpoint"
  resource_group_name = var.resource_group_name
  display_name        = "cosmosdb-document-endpoint"
  value               = var.cosmosdb_document_endpoint
  secret              = false
}

resource "azurerm_api_management_named_value" "user_assigned_identity_client_id" {
  api_management_name = azurerm_api_management.api_management.name
  name                = "user-assigned-identity-client-id"
  resource_group_name = var.resource_group_name
  display_name        = "user-assigned-identity-client-id"
  value               = var.user_assigned_identity_client_id
  secret              = false
}

resource "azurerm_api_management_named_value" "tenant_id" {
  api_management_name = azurerm_api_management.api_management.name
  name                = "tenant-id"
  resource_group_name = var.resource_group_name
  display_name        = "tenant-id"
  value               = var.tenant_id
  secret              = false
}

resource "azurerm_api_management_named_value" "openai_service_principal_audience" {
  api_management_name = azurerm_api_management.api_management.name
  name                = "openai-service-principal-audience"
  resource_group_name = var.resource_group_name
  display_name        = "openai-service-principal-audience"
  value               = var.openai_service_principal_audience
  secret              = false
}