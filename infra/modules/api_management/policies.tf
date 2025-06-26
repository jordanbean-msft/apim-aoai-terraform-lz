resource "azurerm_api_management_api_policy" "openai_api_policy" {
  api_management_name = azapi_resource.api_management.name
  resource_group_name = var.resource_group_name
  api_name            = azurerm_api_management_api.openai_api.name
  xml_content         = file("${path.module}/policies/openai.xml")
  depends_on = [
    azurerm_api_management_policy_fragment.get_access_token_to_openai_policy,
    azurerm_api_management_policy_fragment.openai_event_hub_logging_inbound_policy,
    azurerm_api_management_policy_fragment.openai_event_hub_logging_outbound_policy,
    azurerm_api_management_policy_fragment.setup_correlation_id_policy,
    azurerm_api_management_policy_fragment.generate_partition_key_policy,
    azurerm_api_management_named_value.openai_semantic_cache_store_duration,
    azurerm_api_management_policy_fragment.ai_foundry_cors_policy
  ]
}

resource "azurerm_api_management_policy_fragment" "ai_foundry_cors_policy" {
  api_management_id = azapi_resource.api_management.id
  name              = "ai-foundry-cors"
  value             = file("${path.module}/policies/ai-foundry-cors.xml")
  format            = "rawxml"
}

resource "azurerm_api_management_policy_fragment" "generate_partition_key_policy" {
  api_management_id = azapi_resource.api_management.id
  name              = "generate-partition-key"
  value             = file("${path.module}/policies/generate-partition-key.xml")
  format            = "rawxml"
}

resource "azurerm_api_management_policy_fragment" "setup_correlation_id_policy" {
  api_management_id = azapi_resource.api_management.id
  name              = "setup-correlation-id"
  value             = file("${path.module}/policies/setup-correlation-id.xml")
  format            = "rawxml"
}

resource "azurerm_api_management_policy_fragment" "openai_event_hub_logging_inbound_policy" {
  api_management_id = azapi_resource.api_management.id
  name              = "openai-event-hub-logging-inbound"
  value             = file("${path.module}/policies/openai-event-hub-logging-inbound.xml")
  format            = "rawxml"
  depends_on = [
    azurerm_api_management_named_value.user_assigned_identity_client_id,
    azurerm_api_management_logger.event_hub_logger
  ]
}

resource "azurerm_api_management_policy_fragment" "openai_event_hub_logging_outbound_policy" {
  api_management_id = azapi_resource.api_management.id
  name              = "openai-event-hub-logging-outbound"
  value             = file("${path.module}/policies/openai-event-hub-logging-outbound.xml")
  format            = "rawxml"
  depends_on = [
    azurerm_api_management_named_value.user_assigned_identity_client_id,
    azurerm_api_management_logger.event_hub_logger
  ]
}

resource "azurerm_api_management_policy_fragment" "get_access_token_to_openai_policy" {
  api_management_id = azapi_resource.api_management.id
  name              = "get-access-token-to-openai"
  value             = file("${path.module}/policies/get-access-token-to-openai.xml")
  format            = "rawxml"
  depends_on        = [azurerm_api_management_named_value.user_assigned_identity_client_id]
}
