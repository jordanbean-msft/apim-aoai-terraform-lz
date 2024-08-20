output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.workspace.id
}

output "log_analytics_workspace_customer_id" {
  value = azurerm_log_analytics_workspace.workspace.workspace_id
}

output "log_analytics_workspace_primary_shared_key" {
  value     = azurerm_log_analytics_workspace.workspace.primary_shared_key
  sensitive = true
}