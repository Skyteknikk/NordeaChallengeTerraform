#############################
# OUTPUTS
#############################

output "application_url" {
  value = "https://${var.app_hostname}"
}

output "app_gateway_public_ip" {
  value = module.app_gateway.public_ip_address
}

output "key_vault_id" {
  value = module.keyvault.key_vault_id
}

output "sql_database_server_fqdn" {
  value = module.sql_database.sql_server_fqdn
}

output "sql_database_name" {
  value = module.sql_database.database_name
}