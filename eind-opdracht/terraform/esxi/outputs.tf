output "esxi_vm_names" {
  description = "Namen van de ESXi VM's"
  value       = [for vm in esxi_guest.vm : vm.guest_name]
}

output "esxi_vm_ips" {
  description = "IP-adressen van de ESXi VM's"
  value = {
    for name, vm in esxi_guest.vm :
    name => vm.ip_address
  }
}