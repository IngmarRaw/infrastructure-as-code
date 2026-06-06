output "esxi_vm_name" {
  description = "Naam van de ESXi VM"
  value       = esxi_guest.vm.guest_name
}

output "esxi_vm_ip" {
  description = "IP-adres van de ESXi VM"
  value       = esxi_guest.vm.ip_address
}