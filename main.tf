resource "azurerm_public_ip" "pip" {
  for_each            = var.vm_map
  name                = each.value.pip_name
  resource_group_name = each.value.rg_name
  location            = each.value.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  for_each            = var.vm_map
  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = each.value.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.datasubnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each                        = var.vm_map
  name                            = each.value.v_name
  resource_group_name             = each.value.rg_name
  location                        = each.value.location
  size                            = each.value.size
  admin_username                  = ea.admin_username
  admin_password                  = each.value.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}