output "sql_server_id" {
  value = azurerm_mssql_server.this.id
}

output "sql_server_name" {
  value = azurerm_mssql_server.this.name
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_name" {
  value = azurerm_mssql_database.app.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.sql.id
}