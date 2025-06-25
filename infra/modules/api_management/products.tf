resource "azurerm_api_management_product" "openai_product" {
  api_management_name   = azapi_resource.api_management.name
  resource_group_name   = var.resource_group_name
  approval_required     = true
  display_name          = "Azure OpenAI Product"
  product_id            = "openai-product"
  published             = true
  subscription_required = true
  subscriptions_limit   = 1000
}

resource "azurerm_api_management_product_api" "openai_product_api" {
  resource_group_name = var.resource_group_name
  api_management_name = azapi_resource.api_management.name
  product_id          = azurerm_api_management_product.openai_product.product_id
  api_name            = azurerm_api_management_api.openai_api.name
}

resource "azurerm_api_management_product_group" "openai_product_group" {
  resource_group_name = var.resource_group_name
  api_management_name = azapi_resource.api_management.name
  product_id          = azurerm_api_management_product.openai_product.product_id
  group_name          = "developers"
}
