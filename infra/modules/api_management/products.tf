resource "azurerm_api_management_product" "openai_product" {
  api_management_name   = azurerm_api_management.api_management.name
  resource_group_name   = var.resource_group_name
  approval_required     = true
  display_name          = "Azure OpenAI Product"
  product_id            = "openai-product"
  published             = true
  subscription_required = true
  subscriptions_limit   = 1000
}