resource "azurerm_api_management_api_policy" "openai_api_policy" {
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  api_name            = azurerm_api_management_api.openai_api.name
  xml_content         = file("${path.module}/policies/openai.xml")
  depends_on = [
    azurerm_api_management_policy_fragment.openai_event_hub_logging_inbound_policy,
    azurerm_api_management_policy_fragment.openai_event_hub_logging_outbound_policy,
    azurerm_api_management_policy_fragment.setup_correlation_id_policy,
    azurerm_api_management_policy_fragment.generate_partition_key_policy,
    azurerm_api_management_named_value.openai_semantic_cache_store_duration,
    azurerm_api_management_policy_fragment.ai_foundry_cors_policy,
    azurerm_api_management_policy_fragment.entra_id_authentication_policy,
    azurerm_api_management_policy_fragment.semantic_cache_lookup_policy,
    azurerm_api_management_policy_fragment.semantic_cache_store_policy
  ]
}

resource "azurerm_api_management_policy_fragment" "ai_foundry_cors_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "ai-foundry-cors"
  value             = file("${path.module}/policies/ai-foundry-cors.xml")
  format            = "rawxml"
}

resource "azurerm_api_management_policy_fragment" "generate_partition_key_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "generate-partition-key"
  value             = file("${path.module}/policies/generate-partition-key.xml")
  format            = "rawxml"
}

resource "azurerm_api_management_policy_fragment" "setup_correlation_id_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "setup-correlation-id"
  value             = file("${path.module}/policies/setup-correlation-id.xml")
  format            = "rawxml"
}

resource "azurerm_api_management_policy_fragment" "openai_event_hub_logging_inbound_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "openai-event-hub-logging-inbound"
  value             = file("${path.module}/policies/openai-event-hub-logging-inbound.xml")
  format            = "rawxml"
  depends_on = [
    azurerm_api_management_named_value.user_assigned_identity_client_id,
    azurerm_api_management_logger.event_hub_logger
  ]
}

resource "azurerm_api_management_policy_fragment" "openai_event_hub_logging_outbound_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "openai-event-hub-logging-outbound"
  value             = file("${path.module}/policies/openai-event-hub-logging-outbound.xml")
  format            = "rawxml"
  depends_on = [
    azurerm_api_management_named_value.user_assigned_identity_client_id,
    azurerm_api_management_logger.event_hub_logger
  ]
}

resource "azurerm_api_management_policy_fragment" "entra_id_authentication_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "entra-id-authentication"
  value             = file("${path.module}/policies/entra-id-authentication.xml")
  format            = "rawxml"
  depends_on = [
    azurerm_api_management_named_value.require_entra_id_authentication,
    azurerm_api_management_named_value.openai_service_principal_audience,
    azurerm_api_management_named_value.tenant_id
  ]
}

resource "azurerm_api_management_policy_fragment" "semantic_cache_lookup_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "semantic-cache-lookup"
  value             = file("${path.module}/policies/semantic-cache-loookup.xml")
  format            = "rawxml"
  depends_on = [
    azurerm_api_management_named_value.openai_semantic_cache_embedding_backend_id,
    azurerm_api_management_named_value.openai_semantic_cache_lookup_score_threshold
  ]
}

resource "azurerm_api_management_policy_fragment" "semantic_cache_store_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "semantic-cache-store"
  value             = file("${path.module}/policies/semantic-cache-store.xml")
  format            = "rawxml"
  depends_on = [
    azurerm_api_management_named_value.use_semantic_caching,
    azurerm_api_management_named_value.openai_semantic_cache_store_duration
  ]
}
