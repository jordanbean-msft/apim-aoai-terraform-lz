output "name" {
  description = "Specifies the name of the virtual network"
  value       = data.azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  description = "Specifies the resource id of the virtual network"
  value       = data.azurerm_virtual_network.vnet.id
}

output "api_management_subnet_id" {
  description = "value of the api_management_subnet_id"
  value       = "${data.azurerm_virtual_network.vnet.id}/subnets/${var.api_management_subnet_name}"
}

output "private_endpoint_subnet_id" {
  description = "value of the private_endpoint_subnet_id"
  value       = "${data.azurerm_virtual_network.vnet.id}/subnets/${var.private_endpoint_subnet_name}"
}

output "ai_studio_subnet_id" {
  description = "value of the ai_studio_subnet_id"
  value       = "${data.azurerm_virtual_network.vnet.id}/subnets/${var.ai_studio_subnet_name}"
}

output "function_app_subnet_id" {
  description = "value of the function_app_subnet_id"
  value       = "${data.azurerm_virtual_network.vnet.id}/subnets/${var.function_app_subnet_name}"
}