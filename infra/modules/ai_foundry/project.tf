resource "azurecaf_name" "ai_foundry_project_name" {
  name          = "afp-${var.resource_token}"
  resource_type = "azurerm_cognitive_account"
  random_length = 0
  clean_input   = true
}

# resource "azapi_resource" "ai_foundry_project" {
#   type                      = "Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview"
#   name                      = azurecaf_name.ai_foundry_project_name.result
#   parent_id                 = azapi_resource.ai_foundry_account.id
#   location                  = var.location
#   schema_validation_enabled = false

#   body = {
#     sku = {
#       name = "S0"
#     }
#     # identity = {
#     #   type = "SystemAssigned"
#     # }
#     identity = {
#       type = "UserAssigned"
#       userAssignedIdentities = {
#         "${var.user_assigned_identity_id}" = {}
#       }
#     }

#     properties = {
#       displayName = "default-project"
#       description = "A default project for the AI Foundry account with network secured deployed Agent"
#     }
#   }
# }

# resource "azapi_resource" "conn_cosmosdb" {
#   type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
#   name                      = var.cosmos_db_account_name
#   parent_id                 = azapi_resource.ai_foundry_project.id
#   schema_validation_enabled = false

#   body = {
#     name = var.cosmos_db_account_name
#     properties = {
#       category = "CosmosDB"
#       target   = var.cosmos_db_account_endpoint
#       authType = "AAD"
#       metadata = {
#         ApiType    = "Azure"
#         ResourceId = var.cosmos_db_account_id
#         location   = var.location
#       }
#     }
#   }
# }

# ## Create the AI Foundry project connection to Azure Storage Account
# ##
# resource "azapi_resource" "conn_storage" {
#   type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
#   name                      = var.storage_account_name
#   parent_id                 = azapi_resource.ai_foundry_project.id
#   schema_validation_enabled = false
#   body = {
#     name = var.storage_account_name
#     properties = {
#       category = "AzureStorageAccount"
#       target   = "https://${var.storage_account_name}.blob.core.windows.net"
#       authType = "AAD"
#       metadata = {
#         ApiType    = "Azure"
#         ResourceId = var.storage_account_id
#         location   = var.location
#       }
#     }
#   }
# }

# ## Create the AI Foundry project connection to AI Search
# ##
# resource "azapi_resource" "conn_aisearch" {
#   type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
#   name                      = var.ai_search_name
#   parent_id                 = azapi_resource.ai_foundry_project.id
#   schema_validation_enabled = false

#   body = {
#     name = var.ai_search_name
#     properties = {
#       category = "CognitiveSearch"
#       target   = "https://${var.ai_search_name}.search.windows.net"
#       authType = "AAD"
#       metadata = {
#         ApiType    = "Azure"
#         ApiVersion = "2024-05-01-preview"
#         ResourceId = var.ai_search_id
#         location   = var.location
#       }
#     }
#   }
# }

# resource "azurerm_role_assignment" "cosmosdb_operator_ai_foundry_project" {
#   name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${var.user_assigned_identity_principal_id}${var.resource_group_name}cosmosdboperator")
#   scope                = var.cosmos_db_account_id
#   role_definition_name = "Cosmos DB Operator"
#   principal_id         = var.user_assigned_identity_principal_id #azapi_resource.ai_foundry_project.output.identity.principalId
# }

# resource "azurerm_role_assignment" "storage_blob_data_contributor_ai_foundry_project" {
#   name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${var.user_assigned_identity_principal_id}${var.storage_account_name}storageblobdatacontributor")
#   scope                = var.storage_account_id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = var.user_assigned_identity_principal_id # azapi_resource.ai_foundry_project.output.identity.principalId
# }

# resource "azurerm_role_assignment" "search_index_data_contributor_ai_foundry_project" {
#   name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${var.user_assigned_identity_principal_id}${var.ai_search_name}searchindexdatacontributor")
#   scope                = var.ai_search_id
#   role_definition_name = "Search Index Data Contributor"
#   principal_id         = var.user_assigned_identity_principal_id # azapi_resource.ai_foundry_project.output.identity.principalId
# }

# resource "azurerm_role_assignment" "search_service_contributor_ai_foundry_project" {
#   name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${var.user_assigned_identity_principal_id}${var.ai_search_name}searchservicecontributor")
#   scope                = var.ai_search_id
#   role_definition_name = "Search Service Contributor"
#   principal_id         = var.user_assigned_identity_principal_id # azapi_resource.ai_foundry_project.output.identity.principalId
# }

# resource "azapi_resource" "ai_foundry_project_capability_host" {
#   type                      = "Microsoft.CognitiveServices/accounts/projects/capabilityHosts@2025-04-01-preview"
#   name                      = "caphostproj"
#   parent_id                 = azapi_resource.ai_foundry_project.id
#   schema_validation_enabled = false

#   body = {
#     properties = {
#       capabilityHostKind = "Agents"
#       vectorStoreConnections = [
#         azapi_resource.conn_aisearch.name
#       ]
#       storageConnections = [
#         azapi_resource.conn_storage.name
#       ]
#       threadStorageConnections = [
#         azapi_resource.conn_cosmosdb.name
#       ]
#     }
#   }
# }

# resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_db_sql_role_aifp_user_thread_message_store" {
#   depends_on = [
#     azapi_resource.ai_foundry_project_capability_host
#   ]
#   name                = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}userthreadmessage_dbsqlrole")
#   resource_group_name = var.resource_group_name
#   account_name        = var.cosmos_db_account_name
#   scope               = "${var.cosmos_db_account_id}/dbs/enterprise_memory/colls/${azurecaf_name.ai_foundry_project_name.result}-thread-message-store"
#   role_definition_id  = "${var.cosmos_db_account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
#   principal_id        = azapi_resource.ai_foundry_project.output.identity.principalId
# }

# resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_db_sql_role_aifp_system_thread_name" {
#   depends_on = [
#     azurerm_cosmosdb_sql_role_assignment.cosmosdb_db_sql_role_aifp_user_thread_message_store
#   ]
#   name                = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}systemthread_dbsqlrole")
#   resource_group_name = var.resource_group_name
#   account_name        = var.cosmos_db_account_name
#   scope               = "${var.cosmos_db_account_id}/dbs/enterprise_memory/colls/${azurecaf_name.ai_foundry_project_name.result}-system-thread-message-store"
#   role_definition_id  = "${var.cosmos_db_account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
#   principal_id        = var.user_assigned_identity_principal_id #azapi_resource.ai_foundry_project.output.identity.principalId
# }

# resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_db_sql_role_aifp_entity_store_name" {
#   depends_on = [
#     azurerm_cosmosdb_sql_role_assignment.cosmosdb_db_sql_role_aifp_system_thread_name
#   ]
#   name                = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}entitystore_dbsqlrole")
#   resource_group_name = var.resource_group_name
#   account_name        = var.cosmos_db_account_name
#   scope               = "${var.cosmos_db_account_id}/dbs/enterprise_memory/colls/${azurecaf_name.ai_foundry_project_name.result}-agent-entity-store"
#   role_definition_id  = "${var.cosmos_db_account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
#   principal_id        = var.user_assigned_identity_principal_id
# }

# ## Create the necessary data plane role assignments to the Azure Storage Account containers created by the AI Foundry Project
# ##
# resource "azurerm_role_assignment" "storage_blob_data_owner_ai_foundry_project" {
#   name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${var.user_assigned_identity_id}${var.storage_account_name}storageblobdataowner")
#   scope                = var.storage_account_id
#   role_definition_name = "Storage Blob Data Owner"
#   principal_id         = var.user_assigned_identity_principal_id
#   condition_version    = "2.0"
#   condition            = <<-EOT
#   (
#     (
#       !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags/read'})
#       AND  !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/filter/action'})
#       AND  !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags/write'})
#     )
#     OR
#     (@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringStartsWithIgnoreCase '${azurecaf_name.ai_foundry_project_name.result}'
#     AND @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringLikeIgnoreCase '*-azureml-agent')
#   )
#   EOT
# }
