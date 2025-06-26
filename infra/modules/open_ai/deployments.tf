resource "azurerm_cognitive_deployment" "cognitive_deployment" {
  for_each = {
    for instance in flatten([
      for pool in var.openai_model_deployments.pools : [
        for openai_instance in pool.instances : [
          for deployment in openai_instance.deployments : {
            name_suffix     = openai_instance.name_suffix
            model_format    = deployment.model.format
            model_name      = deployment.model.name
            model_version   = deployment.model.version
            sku_name        = deployment.sku.name
            sku_capacity    = deployment.sku.capacity
            rai_policy_name = deployment.rai_policy_name
          }
    ]]]) : "${instance.model_name}-${instance.name_suffix}" => instance
  }
  name                 = "${each.value.model_name}-${each.value.model_version}"
  cognitive_account_id = azurerm_cognitive_account.cognitive_account[each.value.name_suffix].id
  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }
  sku {
    name     = each.value.sku_name
    capacity = each.value.sku_capacity
  }
  rai_policy_name = each.value.rai_policy_name
}
