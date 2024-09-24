output "event_hub_namespace_name" {
  value = azurerm_eventhub_namespace.event_hub_namespace.name
}

output "event_hub_central_name" {
  value = azurerm_eventhub.event_hub_central.name
}

output "event_hub_llm_logging_name" {
  value = azurerm_eventhub.event_hub_llm_logging.name
}

output "event_hub_siem_name" {
  value = azurerm_eventhub.event_hub_siem.name
}

output "event_hub_consumer_group_central_llm_replication" {
  value = azurerm_eventhub_consumer_group.central_llm_replication.name
}

output "event_hub_consumer_group_central_siem_replication" {
  value = azurerm_eventhub_consumer_group.central_siem_replication.name
}

output "event_hub_consumer_group_write_to_cosmos" {
  value = azurerm_eventhub_consumer_group.write_to_cosmos.name
}

output "event_hub_consumer_group_siem_logging" {
  value = azurerm_eventhub_consumer_group.siem_logging.name
}

output "event_hub_namespace_fqdn" {
  value = "${azurerm_eventhub_namespace.event_hub_namespace.name}.servicebus.windows.net"
}