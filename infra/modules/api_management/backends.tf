resource "azurerm_api_management_backend" "openai_backend" {
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  name                = "openai-backend"
  url                 = azurerm_api_management_named_value.openai_backend.value
  protocol            = "http"
  title               = "OpenAI Backend"
}