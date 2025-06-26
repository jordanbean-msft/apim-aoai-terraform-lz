output "azure_ai_foundry_id" {
  value = azapi_resource.ai_foundry_account.id
}

output "azure_ai_foundry_name" {
  value = azapi_resource.ai_foundry_account.name
}

output "azure_ai_foundry_endpoint" {
  value = azapi_resource.ai_foundry_account.output.properties.endpoints["AI Foundry API"]
}
