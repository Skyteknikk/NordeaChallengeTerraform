resource "random_string" "kv_suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_key_vault" "this" {
  name = substr(
    "kv${replace(var.name_prefix, "-", "")}${random_string.kv_suffix.result}",
    0,
    24
  )

  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  rbac_authorization_enabled    = true
  tags                          = var.tags
}

resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-kv-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-kv-${var.name_prefix}"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_vault_id]
  }
}