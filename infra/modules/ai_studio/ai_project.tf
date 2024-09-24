// Azure AI Project
resource "azapi_resource" "ai_project" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-04-01-preview"
  name      = "ai-project-${var.resource_token}"
  location  = var.location
  parent_id = var.resource_group_id
  tags      = var.tags
  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      description   = "Central AI Project"
      friendlyName  = "Central AI Project"
      hubResourceId = azapi_resource.ai_hub.id
    }
    kind = "Project"
  })
}

resource "azurerm_role_assignment" "managed_identity_storage_file_data_privileged_contributor_role" {
  scope                = var.storage_account_id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azapi_resource.ai_project.identity[0].principal_id
}

resource "azurerm_role_assignment" "managed_identity_key_vault_secrets_officer_role_role" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azapi_resource.ai_project.identity[0].principal_id
}