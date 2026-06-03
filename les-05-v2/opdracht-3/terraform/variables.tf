variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Naam van de bestaande Azure resource group"
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
  description = "Naam van de Azure VM"
  type        = string
  default     = "les05-opdracht3-vm"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "Admin gebruiker voor de VM"
  type        = string
  default     = "iacuser"
}

variable "ssh_public_key_path" {
  description = "Pad naar de SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "tags" {
  description = "Tags voor Azure resources"
  type        = map(string)

  default = {
    project     = "les-05"
    opdracht    = "opdracht-3"
    managed_by  = "terraform"
    environment = "test"
  }
}