output "name" {
  description = "Specifies the name of the virtual network"
  value       = data.azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  description = "Specifies the resource id of the virtual network"
  value       = data.azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "Contains a list of the the resource id of the subnets"
  value       = { for subnet in azurerm_subnet.subnet : subnet.name => subnet.id }
}

output "api_management_subnet_id" {
  description = "value of the api_management_subnet_id"
  value       = "${data.azurerm_virtual_network.vnet.id}/subnets/${var.api_management_subnet_name}"
}

output "private_endpoint_subnet_id" {
  description = "value of the private_endpoint_subnet_id"
  value       = "${data.azurerm_virtual_network.vnet.id}/subnets/${var.private_endpoint_subnet_name}"
}
