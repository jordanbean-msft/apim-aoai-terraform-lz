// AzAPI AI Services Connection
resource "azapi_resource" "ai_services_connection" {
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-04-01-preview"
  name      = "ais-connection-${var.resource_token}"
  parent_id = azapi_resource.ai_hub.id

  body = jsonencode({
    properties = {
      category      = "AIServices",
      target        = jsondecode(azapi_resource.ai_services_resource.output).properties.endpoint,
      authType      = "AAD",
      isSharedToAll = true,
      metadata = {
        ApiType    = "Azure",
        ResourceId = azapi_resource.ai_services_resource.id
      }
    }
  })
  response_export_values = ["*"]
}