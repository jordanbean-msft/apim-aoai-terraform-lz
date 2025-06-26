resource "azurerm_api_management_api" "openai_api" {
  name                = "AzureOpenAI"
  resource_group_name = var.resource_group_name
  api_management_name = azapi_resource.api_management.name
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

resource "azurerm_api_management_api_operation" "deployments" {
  operation_id        = "deployments"
  api_name            = azurerm_api_management_api.openai_api.name
  api_management_name = azapi_resource.api_management.name
  resource_group_name = var.resource_group_name
  display_name        = "deployments"
  method              = "GET"
  url_template        = "/deployments"
  description         = "Get deployments from one of the AOAI resources which will act as a standard or template for all AOAI resources that are configured behind the APIM"
}

resource "azurerm_api_management_api_operation_policy" "ai_foundry_deployments_api_policy" {
  api_management_name = azapi_resource.api_management.name
  resource_group_name = var.resource_group_name
  api_name            = azurerm_api_management_api.openai_api.name
  operation_id        = azurerm_api_management_api_operation.deployments.operation_id
  xml_content         = file("${path.module}/policies/ai-foundry-deployments.xml")
  depends_on          = [azurerm_api_management_named_value.ai_foundry_deployments_backend_base_url]
}
