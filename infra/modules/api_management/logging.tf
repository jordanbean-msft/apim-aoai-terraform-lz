resource "azurerm_api_management_logger" "application_insights_logging" {
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  name                = "application-insights-logger"
  resource_id         = var.application_insights_id
  application_insights {
    instrumentation_key = var.application_insights_instrumentation_key
  }
}

resource "azurerm_api_management_api_diagnostic" "openai_api_diagnostic" {
  api_management_name       = azurerm_api_management.api_management.name
  resource_group_name       = var.resource_group_name
  api_name                  = azurerm_api_management_api.openai_api.name
  api_management_logger_id  = azurerm_api_management_logger.application_insights_logging.id
  identifier                = "applicationinsights"
  always_log_errors         = true
  http_correlation_protocol = "W3C"

}