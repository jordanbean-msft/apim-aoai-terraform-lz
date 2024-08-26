resource "azurerm_api_management_api_policy" "openai_api_policy" {
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  api_name            = azurerm_api_management_api.openai_api.name
  xml_content         = file("${path.module}/policies/openai.xml")
  depends_on = [
    azurerm_api_management_policy_fragment.get_access_token_to_openai_policy,
    azurerm_api_management_policy_fragment.openai_cosmos_logging_inbound_policy,
    azurerm_api_management_policy_fragment.openai_cosmos_logging_outbound_policy,
    azurerm_api_management_policy_fragment.setup_correlation_id_policy,
    azurerm_api_management_policy_fragment.generate_partition_key_policy,
    azurerm_api_management_policy_fragment.load_balancing_select_backend_policy,
    azurerm_api_management_policy_fragment.load_balancing_define_backends_policy,
    azurerm_api_management_named_value.openai_semantic_cache_store_duration
  ]
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

resource "azurerm_api_management_policy_fragment" "openai_cosmos_logging_inbound_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "openai-cosmos-logging-inbound"
  value             = file("${path.module}/policies/openai-cosmos-logging-inbound.xml")
  format            = "rawxml"
  depends_on = [
    azurerm_api_management_named_value.cosmosdb_scope,
    azurerm_api_management_named_value.cosmosdb_document_endpoint,
    azurerm_api_management_named_value.user_assigned_identity_client_id
  ]
}

resource "azurerm_api_management_policy_fragment" "openai_cosmos_logging_outbound_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "openai-cosmos-logging-outbound"
  value             = file("${path.module}/policies/openai-cosmos-logging-outbound.xml")
  format            = "rawxml"
  depends_on = [
    azurerm_api_management_named_value.cosmosdb_scope,
    azurerm_api_management_named_value.cosmosdb_document_endpoint,
    azurerm_api_management_named_value.user_assigned_identity_client_id
  ]
}

resource "azurerm_api_management_policy_fragment" "get_access_token_to_openai_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "get-access-token-to-openai"
  value             = file("${path.module}/policies/get-access-token-to-openai.xml")
  format            = "rawxml"
  depends_on        = [azurerm_api_management_named_value.user_assigned_identity_client_id]
}

resource "azurerm_api_management_policy_fragment" "load_balancing_select_backend_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "load-balancing-select-backend"
  value             = file("${path.module}/policies/load-balancing-select-backend.xml")
  format            = "rawxml"
  depends_on = [
    azurerm_api_management_policy_fragment.load_balancing_define_backends_policy,
    azurerm_api_management_named_value.openai_semantic_cache_lookup_score_threshold
  ]
}

resource "azurerm_api_management_policy_fragment" "load_balancing_define_backends_policy" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "load-balancing-define-backends"
  value             = file("${path.module}/policies/load-balancing-define-backends.xml")
  format            = "rawxml"
  depends_on = [
  azurerm_api_management_named_value.openai_load_balancing_backends]
}