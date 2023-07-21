output "azurerm_network_interface_bgapp_db" {
  value = azurerm_network_interface.bgapp-db.id
}

output "azurerm_network_interface_bgapp_web" {
  value = azurerm_network_interface.bgapp-web.id
}
