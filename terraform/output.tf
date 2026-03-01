output "vm_ip" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "vm_username" {
  value = azurerm_linux_virtual_machine.vm.admin_username
}

output "acr_name" {
  value = azurerm_container_registry.acr.admin_username
}

output "vm_private_key" {
  value     = tls_private_key.ssh_private_key.private_key_pem
  sensitive = true
}