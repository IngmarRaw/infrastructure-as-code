variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Naam van de bestaande resource group"
  type        = string
}

variable "location" {
  description = "Azure regio"
  type        = string
  default     = "westeurope"
}

variable "virtual_network_name" {
  description = "Naam van het bestaande virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Naam van het bestaande subnet"
  type        = string
}

variable "vm_name" {
  description = "Naam van de Azure webserver VM"
  type        = string
  default     = "les05-webserver"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin user voor de VM"
  type        = string
  default     = "iacuser"
}

variable "ssh_public_key_path" {
  description = "Pad naar de SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  description = "Pad naar de SSH private key voor Ansible inventory"
  type        = string
  default     = "~/.ssh/id_ed25519"
}