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
