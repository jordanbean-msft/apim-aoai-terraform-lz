output "redis_cache_id" {
  description = "The id of the Redis cache"
  value       = azurerm_redis_enterprise_cluster.redis_cache.id
}

output "redis_cache_name" {
  description = "The name of the Redis cache"
  value       = azurerm_redis_enterprise_cluster.redis_cache.name
}

output "redis_cache_primary_connection_string" {
  description = "The primary connection string of the Redis cache"
  value       = "${azurerm_redis_enterprise_cluster.redis_cache.hostname}:10000,password=${azurerm_redis_enterprise_database.redis_cache_db.primary_access_key},ssl=True,abortConnect=False"
  sensitive   = true
}