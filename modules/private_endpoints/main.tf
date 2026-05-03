resource "azurerm_private_endpoint" "sqlmi" {
  name                = "pe-sqlmi-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-sqlmi-${var.name_prefix}"
    private_connection_resource_id = var.sql_managed_instance_id
    subresource_names              = ["managedInstance"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.sqlmi_private_dns_zone_id]
  }
}