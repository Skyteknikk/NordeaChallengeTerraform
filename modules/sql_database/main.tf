resource "random_password" "sql_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#commented out because keyvault is set to prevent use of public network and the requirement does not require this but would be needed in prod..

#resource "azurerm_key_vault_secret" "sql_admin_password" {
# name         = "sqldb-admin-password"
#  value        = random_password.sql_admin.result
#  key_vault_id = var.key_vault_id
#}

resource "azurerm_mssql_server" "this" {
  name                         = "sql-${var.name_prefix}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = random_password.sql_admin.result
  minimum_tls_version          = "1.2"

  public_network_access_enabled = false

  tags = var.tags
}

resource "azurerm_mssql_database" "app" {
  name      = "appdb"
  server_id = azurerm_mssql_server.this.id
  sku_name  = "Basic"

  max_size_gb = 2

  lifecycle {
    prevent_destroy = false #true
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "sql" {
  name                = "pe-sql-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-sql-${var.name_prefix}"
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}