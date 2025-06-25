# ------------------------------------------------------------------------------------------------------
# DEPLOY REDIS
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "redis_cache_name" {
  name          = var.resource_token
  resource_type = "azurerm_redis_cache"
  random_length = 0
  clean_input   = true
}

resource "azurerm_redis_enterprise_cluster" "redis_cache" {
  name                = azurecaf_name.redis_cache_name.result
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "${var.sku_name}-${var.capacity}"
  tags                = var.tags
  zones               = var.zones
}

resource "azurerm_redis_enterprise_database" "redis_cache_db" {
  cluster_id        = azurerm_redis_enterprise_cluster.redis_cache.id
  clustering_policy = "EnterpriseCluster"
  module {
    name = "RediSearch"
  }
  eviction_policy = "NoEviction"
}

module "private_endpoint" {
  source                         = "../private_endpoint"
  name                           = azurerm_redis_enterprise_cluster.redis_cache.name
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  resource_token                 = var.resource_token
  private_connection_resource_id = azurerm_redis_enterprise_cluster.redis_cache.id
  location                       = var.location
  subnet_id                      = var.subnet_id
  subresource_names              = ["redisEnterprise"]

  is_manual_connection = false
}

# resource "azurerm_redis_cache_access_policy_assignment" "data_contributor" {
#   name               = "data-contributor"
#   redis_cache_id     = azurerm_redis_enterprise_cluster.redis_cache.id
#   access_policy_name = "Data Contributor"
#   object_id          = var.user_assigned_identity_object_id
#   object_id_alias    = var.user_assigned_identity_name
# }
