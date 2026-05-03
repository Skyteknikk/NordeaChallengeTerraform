#############################
# RESOURCE GROUP
#############################
resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}

data "azurerm_client_config" "current" {}

module "hub_network" {
  source              = "./modules/hub_network"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

module "spoke_network" {
  source              = "./modules/spoke_network"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  hub_vnet_id         = module.hub_network.hub_vnet_id
  firewall_private_ip = module.hub_network.firewall_private_ip
  tags                = local.tags
}

module "bastion" {
  source              = "./modules/bastion"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.hub_network.bastion_subnet_id
  tags                = local.tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

module "keyvault" {
  source                     = "./modules/keyvault"
  name_prefix                = local.safe_prefix
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  private_endpoint_subnet_id = module.spoke_network.private_endpoint_subnet_id
  private_dns_zone_vault_id  = module.spoke_network.keyvault_private_dns_zone_id
  tags                       = local.tags
}

module "sql_database" {
  source                     = "./modules/sql_database"
  name_prefix                = local.name_prefix
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  private_endpoint_subnet_id = module.spoke_network.private_endpoint_subnet_id
  private_dns_zone_id        = module.spoke_network.sql_private_dns_zone_id
  key_vault_id               = module.keyvault.key_vault_id
  tags                       = local.tags
}

module "app_gateway" {
  source               = "./modules/app_gateway"
  name_prefix          = local.name_prefix
  location             = var.location
  resource_group_name  = azurerm_resource_group.this.name
  subnet_id            = module.spoke_network.app_gateway_subnet_id
  app_hostname         = var.app_hostname
  certificate_pfx_path = var.certificate_pfx_path
  certificate_password = var.certificate_password
  log_analytics_id     = module.monitoring.log_analytics_workspace_id
  tags                 = local.tags
}

module "compute" {
  source                  = "./modules/compute"
  name_prefix             = local.name_prefix
  location                = var.location
  resource_group_name     = azurerm_resource_group.this.name
  subnet_id               = module.spoke_network.web_subnet_id
  admin_username          = var.admin_username
  ssh_public_key          = var.ssh_public_key
  backend_address_pool_id = module.app_gateway.backend_address_pool_id
  custom_data_path        = "${path.module}/cloud-init/nginx.yaml"
  tags                    = local.tags
}

module "dns" {
  source                = "./modules/dns"
  resource_group_name   = azurerm_resource_group.this.name
  domain_name           = var.domain_name
  app_record_name       = replace(var.app_hostname, ".${var.domain_name}", "")
  app_gateway_public_ip = module.app_gateway.public_ip_address
  tags                  = local.tags
}

module "hub_spoke_peering" {
  source              = "./modules/hub_spoke_peering"
  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.this.name
  hub_vnet_name       = module.hub_network.hub_vnet_name
  spoke_vnet_id       = module.spoke_network.vnet_id
}

resource "azurerm_role_assignment" "vmss_kv_reader" {
  scope                = module.keyvault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.compute.vmss_identity_principal_id
}