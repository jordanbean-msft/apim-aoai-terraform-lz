output "cosmosdb_account_name" {
  value = azurerm_cosmosdb_account.cosmosdb_account.name
}

output "cosmosdb_account_endpoint" {
  value = azurerm_cosmosdb_account.cosmosdb_account.endpoint
}

output "cosmosdb_sql_database_name" {
  value = azurerm_cosmosdb_sql_database.cosmosdb_sql_database.name
}

output "cosmosdb_sql_container_name" {
  value = azurerm_cosmosdb_sql_container.cosmosdb_sql_container.name
}

output "cosmosdb_account_connection_string" {
  value = azurerm_cosmosdb_account.cosmosdb_account.primary_sql_connection_string
}
