resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                = "vmss-web-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_B2s"
  instances           = 2
  admin_username      = var.admin_username
  custom_data         = base64encode(file(var.custom_data_path))
  upgrade_mode        = "Automatic"
  tags                = var.tags

  disable_password_authentication = true

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  network_interface {
    name    = "nic-web"
    primary = true

    ip_configuration {
      name                                         = "ipconfig-web"
      primary                                      = true
      subnet_id                                    = var.subnet_id
      application_gateway_backend_address_pool_ids = [var.backend_address_pool_id]
    }
  }
}