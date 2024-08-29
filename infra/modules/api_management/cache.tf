resource "azurerm_api_management_redis_cache" "redis_cache" {
  name              = var.redis_cache_name
  api_management_id = azurerm_api_management.api_management.id
  connection_string = var.redis_cache_connection_string
  redis_cache_id    = var.redis_cache_id
  cache_location    = var.location
  description       = var.redis_cache_name
}