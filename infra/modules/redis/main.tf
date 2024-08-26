terraform {
  required_providers {
    azurerm = {
      version = "~>4.0.1"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.28"
    }
  }
}
# ------------------------------------------------------------------------------------------------------
# DEPLOY REDIS
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "redis_cache_name" {
  name          = var.resource_token
  resource_type = "azurerm_redis_cache"
  random_length = 0
  clean_input   = true
}

resource "azurerm_redis_cache" "redis_cache" {
  name                               = azurecaf_name.redis_cache_name.result
  location                           = var.location
  resource_group_name                = var.resource_group_name
  tags                               = var.tags
  capacity                           = var.capacity
  family                             = var.family
  sku_name                           = var.sku_name
  minimum_tls_version                = "1.2"
  public_network_access_enabled      = false
  access_keys_authentication_enabled = false
  redis_configuration {
    active_directory_authentication_enabled = true
  }
}


module "private_endpoint" {
  source                         = "../private_endpoint"
  name                           = azurerm_redis_cache.redis_cache.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_redis_cache.redis_cache.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_name               = "redisCache"
  is_manual_connection           = false
}

resource "azurerm_redis_cache_access_policy_assignment" "data_contributor" {
  name               = "data-contributor"
  redis_cache_id     = azurerm_redis_cache.redis_cache.id
  access_policy_name = "Data Contributor"
  object_id          = var.user_assigned_identity_object_id
  object_id_alias    = var.user_assigned_identity_name
}