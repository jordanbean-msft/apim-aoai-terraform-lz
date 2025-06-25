# ------------------------------------------------------------------------------------------------------
# Deploy event hub
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "event_hub_namespace_name" {
  name          = var.resource_token
  resource_type = "azurerm_eventhub_namespace"
  random_length = 0
  clean_input   = true
}

resource "azurerm_eventhub_namespace" "event_hub_namespace" {
  name                          = azurecaf_name.event_hub_namespace_name.result
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.event_hub_namespace_sku
  capacity                      = var.capacity
  auto_inflate_enabled          = true
  maximum_throughput_units      = var.maximum_throughput_units
  tags                          = var.tags
  public_network_access_enabled = false
  network_rulesets = [{
    default_action                 = "Deny"
    trusted_service_access_enabled = true
    public_network_access_enabled  = false
    ip_rule                        = []
    virtual_network_rule           = []
  }]
}

resource "azurerm_eventhub" "event_hub_central" {
  name                = "central-llm-logging"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  partition_count     = var.partition_count
  message_retention   = var.message_retention
}

resource "azurerm_eventhub" "event_hub_siem" {
  name                = "siem-logging"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  partition_count     = var.partition_count
  message_retention   = var.message_retention
}

resource "azurerm_eventhub" "event_hub_llm_logging" {
  name                = "llm-logging"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  partition_count     = var.partition_count
  message_retention   = var.message_retention
}

resource "azurerm_eventhub_consumer_group" "central_llm_replication" {
  name                = "central-llm-replication"
  eventhub_name       = azurerm_eventhub.event_hub_central.name
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_eventhub_consumer_group" "central_siem_replication" {
  name                = "central-siem-replication"
  eventhub_name       = azurerm_eventhub.event_hub_central.name
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_eventhub_consumer_group" "write_to_cosmos" {
  name                = "write-to-cosmos"
  eventhub_name       = azurerm_eventhub.event_hub_llm_logging.name
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_eventhub_consumer_group" "siem_logging" {
  name                = "siem-logging"
  eventhub_name       = azurerm_eventhub.event_hub_siem.name
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "managed_identity_azure_event_hubs_data_sender_role" {
  scope                = azurerm_eventhub_namespace.event_hub_namespace.id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = var.managed_identity_principal_id
}

resource "azurerm_role_assignment" "managed_identity_azure_event_hubs_data_receiver_role" {
  scope                = azurerm_eventhub_namespace.event_hub_namespace.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = var.managed_identity_principal_id
}

module "private_endpoint" {
  source                         = "../private_endpoint"
  name                           = azurerm_eventhub_namespace.event_hub_namespace.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_eventhub_namespace.event_hub_namespace.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["namespace"]
  is_manual_connection           = false
}
