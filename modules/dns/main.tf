resource "azurerm_dns_zone" "this" {
  name                = var.domain_name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  #lifecycle {
  # prevent_destroy = true
  #}
}

resource "azurerm_dns_a_record" "app" {
  name                = var.app_record_name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.app_gateway_public_ip]
  tags                = var.tags
}