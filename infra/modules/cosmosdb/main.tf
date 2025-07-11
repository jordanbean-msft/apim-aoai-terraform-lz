# ------------------------------------------------------------------------------------------------------
# Deploy log analytics workspace
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "cosmosdb_account_name" {
  name          = var.resource_token
  resource_type = "azurerm_cosmosdb_account"
  random_length = 0
  clean_input   = true
}

resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                                  = azurecaf_name.cosmosdb_account_name.result
  location                              = var.location
  tags                                  = var.tags
  resource_group_name                   = var.resource_group_name
  public_network_access_enabled         = false
  network_acl_bypass_for_azure_services = true
  local_authentication_disabled         = false
  kind                                  = "GlobalDocumentDB"
  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = var.zone_redundant
  }
  offer_type = "Standard"
}

resource "azurerm_cosmosdb_sql_database" "cosmosdb_sql_database" {
  name                = "chat-log-db"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  autoscale_settings {
    max_throughput = var.max_throughput
  }
}

resource "azurerm_cosmosdb_sql_container" "cosmosdb_sql_container" {
  name                = "chat-log-container"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_sql_database.cosmosdb_sql_database.name
  partition_key_paths = [
    "/pk"
  ]
  partition_key_version = 1
  conflict_resolution_policy {
    mode                     = "LastWriterWins"
    conflict_resolution_path = "/_ts"
  }
  indexing_policy {
    indexing_mode = "consistent"
    included_path {
      path = "/*"
    }
  }
  default_ttl = var.document_time_to_live
}

module "private_endpoint" {
  source                         = "../private_endpoint"
  name                           = azurerm_cosmosdb_account.cosmosdb_account.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_cosmosdb_account.cosmosdb_account.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["Sql"]
  is_manual_connection           = false
}

data "azurerm_cosmosdb_sql_role_definition" "cosmosdb_built_in_data_contributor" {
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  role_definition_id  = "00000000-0000-0000-0000-000000000002" #https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#built-in-role-definitions
}

resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_built_in_data_contributor_role_assignment_to_user_assigned_managed_identity" {
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.cosmosdb_built_in_data_contributor.id
  principal_id        = var.user_assigned_identity_principal_id
  scope               = azurerm_cosmosdb_account.cosmosdb_account.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_built_in_data_contributor_role_assignment_to_principal_id" {
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.cosmosdb_built_in_data_contributor.id
  principal_id        = var.principal_id
  scope               = azurerm_cosmosdb_account.cosmosdb_account.id
}

resource "azurerm_monitor_diagnostic_setting" "cosmos_db_logging" {
  name                       = "cosmos-db-logging"
  target_resource_id         = azurerm_cosmosdb_account.cosmosdb_account.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "Requests"
  }
  enabled_metric {
    category = "SLI"
  }
}
