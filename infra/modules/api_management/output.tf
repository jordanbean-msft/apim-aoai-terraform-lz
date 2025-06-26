output "api_management_name" {
  value = azapi_resource.api_management.name
}

output "api_management_id" {
  value = azapi_resource.api_management.id
}

output "api_management_gateway_url" {
  value = azapi_resource.api_management.output.properties.gatewayUrl
}
