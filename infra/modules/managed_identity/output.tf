output "user_assigned_identity_id" {
  description = "Specifies the resource id of the user assigned identity."
  value       = azurerm_user_assigned_identity.managed_identity.id
}

output "user_assigned_identity_principal_id" {
  description = "Specifies the principal id of the user assigned identity."
  value       = azurerm_user_assigned_identity.managed_identity.principal_id
}

output "user_assigned_identity_client_id" {
  description = "Specifies the client id of the user assigned identity."
  value       = azurerm_user_assigned_identity.managed_identity.client_id
}

output "user_assigned_identity_object_id" {
  description = "Specifies the object_id of the user assigned identity."
  value       = azurerm_user_assigned_identity.managed_identity.principal_id
}

