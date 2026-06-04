output "azure_vm_name" {
  description = "Naam van de Azure VM"
  value       = azurerm_linux_virtual_machine.azure_vm.name
}

output "azure_vm_public_ip" {
  description = "Publiek IP-adres van de Azure VM"
  value       = azurerm_public_ip.azure_vm_pip.ip_address
}

output "azure_vm_private_ip" {
  description = "Privé IP-adres van de Azure VM"
  value       = azurerm_network_interface.azure_vm_nic.private_ip_address
}