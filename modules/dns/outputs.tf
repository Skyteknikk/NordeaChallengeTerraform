output "dns_zone_id" {
  value = azurerm_dns_zone.this.id
}

output "dns_zone_name" {
  value = azurerm_dns_zone.this.name
}

output "name_servers" {
  value = azurerm_dns_zone.this.name_servers
}

output "app_fqdn" {
  value = "${azurerm_dns_a_record.app.name}.${azurerm_dns_zone.this.name}"
}