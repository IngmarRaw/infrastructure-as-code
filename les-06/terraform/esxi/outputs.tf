output "esxi_vm_name" {
  description = "Naam van de ESXi VM"
  value       = esxi_guest.esxi_vm.guest_name
}