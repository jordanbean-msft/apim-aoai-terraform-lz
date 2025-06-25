resource "azurerm_api_management_identity_provider_aad" "identity_provider_aad" {
  resource_group_name = var.resource_group_name
  api_management_name = azapi_resource.api_management.name
  client_id           = var.openai_service_principal_client_id
  client_secret       = "NOT_THE_REAL_SECRET"
  allowed_tenants = [
    var.tenant_id
  ]
  signin_tenant  = var.tenant_id
  client_library = "MSAL-2"

  lifecycle {
    ignore_changes = [
      client_secret
    ]
  }
}
