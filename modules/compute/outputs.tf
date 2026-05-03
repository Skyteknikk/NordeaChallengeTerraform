output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.web.id
}

output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.web.name
}

output "vmss_identity_principal_id" {
  value = azurerm_linux_virtual_machine_scale_set.web.identity[0].principal_id
}