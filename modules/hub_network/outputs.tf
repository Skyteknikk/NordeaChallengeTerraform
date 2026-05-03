output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  value = azurerm_virtual_network.hub.name
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}

output "firewall_private_ip" {
  value = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "firewall_id" {
  value = azurerm_firewall.this.id
}