output "azure_cognitive_services_endpoints" {
  value = [
    for deployment in var.openai_model_deployments : {
      key      = deployment.name_suffix
      name     = azurecaf_name.cognitiveservices_name[deployment.name_suffix].result
      endpoint = azurerm_cognitive_account.cognitive_account[deployment.name_suffix].endpoint,
      priority = deployment.priority
    }
  ]
}

output "azure_cognitive_services_deployment_names" {
  value = toset([
    for deployment in azurerm_cognitive_deployment.cognitive_deployment : deployment.name
  ])
}
