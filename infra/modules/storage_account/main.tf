# ------------------------------------------------------------------------------------------------------
# Deploy Storage Account
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "storage_account_name" {
  name          = var.resource_token
  resource_type = "azurerm_storage_account"
  random_length = 0
  clean_input   = true
}

resource "azurerm_storage_account" "storage_account" {
  name                            = azurecaf_name.storage_account_name.result
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  tags                            = var.tags
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_storage_container" "function_app_container" {
  name               = "func-write-to-cosmos"
  storage_account_id = azurerm_storage_account.storage_account.id
}

# resource "azurerm_storage_share" "function_app_share" {
#   name                 = "func-write-to-cosmos"
#   storage_account_name = azurerm_storage_account.storage_account.name
#   quota                = 50
# }

resource "azurerm_role_assignment" "managed_identity_storage_blob_data_owner_role" {
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.managed_identity_principal_id
}

module "private_endpoint_blob" {
  source                         = "../private_endpoint"
  name                           = "${azurerm_storage_account.storage_account.name}-blob"
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_storage_account.storage_account.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["blob"]
  is_manual_connection           = false
}

module "private_endpoint_file" {
  source                         = "../private_endpoint"
  name                           = "${azurerm_storage_account.storage_account.name}-file"
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_storage_account.storage_account.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["file"]
  is_manual_connection           = false
}

module "private_endpoint_queue" {
  source                         = "../private_endpoint"
  name                           = "${azurerm_storage_account.storage_account.name}-queue"
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_storage_account.storage_account.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["queue"]
  is_manual_connection           = false
}

module "private_endpoint_table" {
  source                         = "../private_endpoint"
  name                           = "${azurerm_storage_account.storage_account.name}-table"
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_storage_account.storage_account.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["table"]
  is_manual_connection           = false
}

module "private_endpoint_web" {
  source                         = "../private_endpoint"
  name                           = "${azurerm_storage_account.storage_account.name}-web"
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_storage_account.storage_account.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["web"]
  is_manual_connection           = false
}
