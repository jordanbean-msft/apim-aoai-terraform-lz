resource "azurerm_api_management_product" "openai_product" {
  api_management_name   = azurerm_api_management.api_management.name
  resource_group_name   = var.resource_group_name
  approval_required     = false
  display_name          = "Azure OpenAI Product"
  description           = "Azure OpenAI Product"
  product_id            = "openai-product"
  published             = true
  subscription_required = false
  subscriptions_limit   = 0
}

resource "azurerm_api_management_product_api" "openai_product_api" {
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api_management.name
  product_id          = azurerm_api_management_product.openai_product.product_id
  api_name            = azurerm_api_management_api.openai_api.name
}

resource "azurerm_api_management_product_group" "openai_product_group" {
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.api_management.name
  product_id          = azurerm_api_management_product.openai_product.product_id
  group_name          = "developers"
}
