output "azure_vm_names" {
  description = "Namen van de Azure VM's"
  value       = [for vm in azurerm_linux_virtual_machine.vm : vm.name]
}

output "azure_vm_public_ips" {
  description = "Publieke IP-adressen van de Azure VM's"
  value = {
    for name, pip in azurerm_public_ip.vm_pip :
    name => pip.ip_address
  }
}

output "azure_vm_private_ips" {
  description = "Privé IP-adressen van de Azure VM's"
  value = {
    for name, nic in azurerm_network_interface.vm_nic :
    name => nic.private_ip_address
  }
}