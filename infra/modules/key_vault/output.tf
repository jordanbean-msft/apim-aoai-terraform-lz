output "azure_key_vault_endpoint" {
  value     = azurerm_key_vault.kv.vault_uri
  sensitive = false
}

output "key_vault_id" {
  value     = azurerm_key_vault.kv.id
  sensitive = false
}

output "key_vault_name" {
  value     = azurerm_key_vault.kv.name
  sensitive = false
}

output "openai_service_principal_client_secret_name" {
  value     = var.openai_service_principal_client_secret_name
  sensitive = false
}