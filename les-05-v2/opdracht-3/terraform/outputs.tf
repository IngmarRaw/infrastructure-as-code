output "vm_names" {
  description = "Namen van de aangemaakte Azure VM's"
  value       = [for vm in azurerm_linux_virtual_machine.vm : vm.name]
}

output "public_ip_addresses" {
  description = "Publieke IP-adressen van de aangemaakte Azure VM's"
  value       = {
    for name, pip in azurerm_public_ip.vm_pip :
    name => pip.ip_address
  }
}

output "resource_group_name" {
  description = "Resource group waarin de VM's zijn aangemaakt"
  value       = var.resource_group_name
}