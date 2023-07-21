output "public_ip_address" {
  value = azurerm_linux_virtual_machine.bgapp-web-vm.public_ip_address
}

output "private_ip_address" {
  value = azurerm_linux_virtual_machine.bgapp-web-vm.private_ip_address
}