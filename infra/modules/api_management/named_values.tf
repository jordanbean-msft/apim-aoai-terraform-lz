# resource "azurerm_api_management_named_value" "openai_backend" {
#   for_each            = { for endpoint in var.openai_endpoints : endpoint.key => endpoint }
#   api_management_name = azurerm_api_management.api_management.name
#   name                = "openai-backend-${each.name}"
#   resource_group_name = var.resource_group_name
#   display_name        = "openai-backend-${each.name}"
#   value               = "${each.value.endpoint}openai/"
#   secret              = false
# }

resource "azurerm_api_management_named_value" "openai_token_limit_per_minute" {
  api_management_name = azurerm_api_management.api_management.name
  name                = "openai-token-limit-per-minute"
  resource_group_name = var.resource_group_name
  display_name        = "openai-token-limit-per-minute"
  value               = var.openai_token_limit_per_minute
  secret              = false
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

resource "azurerm_api_management_named_value" "openai_load_balancing_backends" {
  api_management_name = azurerm_api_management.api_management.name
  name                = "openai-load-balancing-backends"
  resource_group_name = var.resource_group_name
  display_name        = "openai-load-balancing-backends"
  value = jsonencode([for endpoint in var.openai_endpoints : {
    backend-id   = endpoint.name
    priority     = endpoint.priority
    isThrottling = false
    retryAfter   = "1/1/0001 12:00:00 AM"
  }])
  secret = false
}