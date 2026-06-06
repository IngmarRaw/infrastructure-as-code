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
  description = "Naam van het bestaande Azure virtual network"
  type        = string
  sensitive   = true
}

variable "subnet_name" {
  description = "Naam van het bestaande Azure subnet"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "Naam van de Azure VM"
  type        = string
  default     = "eindopdracht-azure-vm"
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
  description = "SSH public key inhoud voor de Azure VM"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags voor Azure resources"
  type        = map(string)

  default = {
    project     = "eind-opdracht"
    platform    = "azure"
    role        = "dockerhost"
    managed_by  = "terraform"
    environment = "test"
  }
}