output "vm_name" {
  description = "Naam van de aangemaakte VM"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "public_ip_address" {
  description = "Publiek IP-adres van de VM"
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "resource_group_name" {
  description = "Resource group waarin de VM is aangemaakt"
  value       = var.resource_group_name
}