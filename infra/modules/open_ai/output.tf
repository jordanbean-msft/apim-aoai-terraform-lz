output "azure_cognitive_services_endpoints" {
  value = [
    for deployment in flatten([
      for pool in var.openai_model_deployments.pools : [
        for openai_instance in pool.instances : {
          key       = openai_instance.name_suffix
          pool_name = pool.name
          name      = azurecaf_name.cognitiveservices_name[openai_instance.name_suffix].result
          endpoint  = azurerm_cognitive_account.cognitive_account[openai_instance.name_suffix].endpoint
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
    for cognitive_account in azurerm_cognitive_account.cognitive_account : cognitive_account.id
  ])
}
