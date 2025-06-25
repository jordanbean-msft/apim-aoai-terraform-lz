output "azure_cognitive_services_endpoints" {
  value = [
    for deployment in flatten([
      for pool in var.openai_model_deployments.pools : [
        for openai_instance in pool.instances : {
          key       = openai_instance.name_suffix
          pool_name = pool.name
          name      = azurecaf_name.ai_foundry_account_name.result
          endpoint  = "https://${azapi_resource.ai_foundry_account.name}.openai.azure.com/"
          priority  = openai_instance.priority
    }]]) : deployment
  ]
}

output "azure_cognitive_services_deployment_names" {
  value = toset([
    for deployment in azurerm_cognitive_deployment.cognitive_deployment : deployment.name
  ])
}

output "azure_cognitive_services_ids" {
  value = tolist([
    azapi_resource.ai_foundry_account.id
  ])
}
