output "webserver_name" {
  description = "Naam van de Azure webserver VM"
  value       = azurerm_linux_virtual_machine.webserver.name
}

output "webserver_public_ip" {
  description = "Publiek IP-adres van de webserver"
  value       = azurerm_public_ip.web_pip.ip_address
}

output "ansible_inventory_path" {
  description = "Pad naar de gegenereerde Ansible inventory"
  value       = local_file.ansible_inventory.filename
}