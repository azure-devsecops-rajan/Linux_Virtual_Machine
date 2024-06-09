data "azurerm_subnet" "datasubnet" {
  for_each             = var.vm_map
  name                 = each.value.sub_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.rg_name
}