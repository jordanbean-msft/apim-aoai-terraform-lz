output "azure_key_vault_endpoint" {
  value     = azurerm_key_vault.kv.vault_uri
  sensitive = false
}

output "key_vault_id" {
  value     = azurerm_key_vault.kv.id
  sensitive = false
}