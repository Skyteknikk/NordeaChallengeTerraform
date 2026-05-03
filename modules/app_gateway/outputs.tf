output "public_ip_id" {
  value = azurerm_public_ip.appgw.id
}

output "public_ip_address" {
  value = azurerm_public_ip.appgw.ip_address
}

output "application_gateway_id" {
  value = azurerm_application_gateway.this.id
}

output "backend_address_pool_id" {
  value = one([
    for pool in azurerm_application_gateway.this.backend_address_pool :
    pool.id
    if pool.name == "vmss-backend-pool"
  ])
}