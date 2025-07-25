output "storage_account_id" {
  value = azurerm_storage_account.storage_account.id
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "storage_account_access_key" {
  value     = azurerm_storage_account.storage_account.primary_access_key
  sensitive = true
}

# output "function_app_share_name" {
#   value = azurerm_storage_share.function_app_share.name
# }

output "function_app_container_name" {
  value = azurerm_storage_container.function_app_container.name
}

output "storage_account_connection_string" {
  value     = azurerm_storage_account.storage_account.primary_connection_string
  sensitive = true
}
