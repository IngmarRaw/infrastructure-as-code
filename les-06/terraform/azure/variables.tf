variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Naam van de bestaande Azure resource group"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure regio"
  type        = string
  default     = "westeurope"
}

variable "virtual_network_name" {
  description = "Naam van het bestaande virtual network"
  type        = string
  sensitive   = true
}

variable "subnet_name" {
  description = "Naam van het bestaande subnet"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "Naam van de Azure VM"
  type        = string
  default     = "les06-azure-vm"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "Admin gebruiker voor de Azure VM"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key content voor de Azure VM"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_public_key_path" {
  description = "Lokaal pad naar SSH public key voor handmatig testen"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "tags" {
  description = "Tags voor Azure resources"
  type        = map(string)

  default = {
    project     = "les-06"
    environment = "test"
    platform    = "azure"
    managed_by  = "terraform"
  }
}