resource "azurerm_api_management_backend" "openai_backend" {
  for_each            = { for endpoint in var.openai_endpoints : endpoint.key => endpoint }
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  name                = "openai-backend-${each.value.name}"
  url                 = "${each.value.endpoint}openai/"
  protocol            = "http"
  title               = "OpenAI Backend - ${each.value.name}"
}