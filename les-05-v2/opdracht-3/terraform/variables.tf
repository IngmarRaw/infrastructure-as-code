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

variable "vm_name_prefix" {
  description = "Prefix voor de Azure VM namen"
  type        = string
  default     = "webserver"
}

variable "vm_count" {
  description = "Aantal webservers dat moet worden aangemaakt"
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 3
    error_message = "vm_count moet tussen 1 en 3 liggen."
  }
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
  description = "Pad naar de SSH public key op de self-hosted runner"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags voor Azure resources"
  type        = map(string)

  default = {
    project     = "les-05"
    role        = "webserver"
    opdracht    = "opdracht-3"
    managed_by  = "terraform"
    environment = "test"
  }
}