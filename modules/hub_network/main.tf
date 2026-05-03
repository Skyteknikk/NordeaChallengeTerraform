resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.50.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.50.1.0/26"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.50.2.0/26"]
}

resource "azurerm_public_ip" "firewall" {
  name                = "pip-fw-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "this" {
  name                = "fw-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  tags                = var.tags

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_firewall_network_rule_collection" "allow_web_egress" {
  name                = "allow-web-egress"
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name = "allow-http-https"

    source_addresses = [
      "10.40.2.0/24"
    ]

    destination_ports = [
      "80",
      "443"
    ]

    destination_addresses = [
      "*"
    ]

    protocols = [
      "TCP"
    ]
  }

  rule {
    name = "allow-dns"

    source_addresses = [
      "10.40.2.0/24"
    ]

    destination_ports = [
      "53"
    ]

    destination_addresses = [
      "*"
    ]

    protocols = [
      "TCP",
      "UDP"
    ]
  }
}