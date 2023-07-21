output "public_ip_address" {
  value = azurerm_linux_virtual_machine.bgapp-db-vm.public_ip_address
}

output "private_ip_address" {
  value = azurerm_linux_virtual_machine.bgapp-db-vm.private_ip_address
}