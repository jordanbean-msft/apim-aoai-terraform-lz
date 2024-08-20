output "application_insights_connection_string" {
  value     = azurerm_application_insights.applicationinsights.connection_string
  sensitive = true
}

output "application_insights_name" {
  value     = azurerm_application_insights.applicationinsights.name
  sensitive = false
}

output "application_insights_instrumentation_key" {
  value     = azurerm_application_insights.applicationinsights.instrumentation_key
  sensitive = true
}
