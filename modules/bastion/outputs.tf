output "bastion_host_id" {
  value = azurerm_bastion_host.this.id
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion.ip_address
}