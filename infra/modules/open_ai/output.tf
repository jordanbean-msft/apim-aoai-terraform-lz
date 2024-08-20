output "azure_cognitive_services_endpoint" {
  value = azurerm_cognitive_account.cognitive_account.endpoint
}

output "azure_cognitive_services_key" {
  value     = azurerm_cognitive_account.cognitive_account.primary_access_key
  sensitive = true
}

output "azure_cognitive_services_chat_deployment_name" {
  value = azurerm_cognitive_deployment.chat.name
}

output "azure_cognitive_services_embedding_deployment_name" {
  value = azurerm_cognitive_deployment.embedding.name
}