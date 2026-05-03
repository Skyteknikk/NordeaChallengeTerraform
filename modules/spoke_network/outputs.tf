output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "app_gateway_subnet_id" {
  value = azurerm_subnet.app_gateway.id
}

output "web_subnet_id" {
  value = azurerm_subnet.web.id
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "keyvault_private_dns_zone_id" {
  value = azurerm_private_dns_zone.keyvault.id
}

output "sql_private_dns_zone_id" {
  value = azurerm_private_dns_zone.sql.id
}
