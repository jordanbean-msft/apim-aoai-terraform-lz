output "redis_cache_id" {
  description = "The id of the Redis cache"
  value       = azurerm_redis_cache.redis_cache.id
}

output "redis_cache_name" {
  description = "The name of the Redis cache"
  value       = azurerm_redis_cache.redis_cache.name
}

output "redis_cache_primary_connection_string" {
  description = "The primary connection string of the Redis cache"
  value       = azurerm_redis_cache.redis_cache.primary_connection_string
}