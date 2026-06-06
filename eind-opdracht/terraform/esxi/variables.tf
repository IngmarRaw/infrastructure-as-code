variable "esxi_hostname" {
  description = "ESXi hostnaam of IP-adres"
  type        = string
  sensitive   = true
}

variable "esxi_hostport" {
  description = "ESXi SSH poort"
  type        = string
  default     = "22"
}

variable "esxi_hostssl" {
  description = "ESXi HTTPS poort"
  type        = string
  default     = "443"
}

variable "esxi_username" {
  description = "ESXi gebruikersnaam"
  type        = string
  sensitive   = true
}

variable "esxi_password" {
  description = "ESXi wachtwoord"
  type        = string
  sensitive   = true
}

variable "disk_store" {
  description = "ESXi datastore"
  type        = string
  sensitive   = true
}

variable "virtual_network" {
  description = "ESXi virtual network / port group"
  type        = string
  sensitive   = true
}

variable "ovf_source" {
  description = "Pad of URL naar Ubuntu cloud image OVA/OVF"
  type        = string
  sensitive   = true
}

variable "vm_name_prefix" {
  description = "Prefix voor de ESXi VM naam"
  type        = string
  default     = "database-server"
}

variable "instance_count" {
  description = "Aantal ESXi VM's dat moet worden aangemaakt"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 3
    error_message = "instance_count moet tussen 1 en 3 liggen."
  }
}

variable "admin_username" {
  description = "Admin gebruiker voor de ESXi VM"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key inhoud voor de ESXi VM"
  type        = string
  sensitive   = true
}

variable "boot_disk_size" {
  description = "Bootdisk grootte in GB"
  type        = number
  default     = 20
}

variable "memory_mb" {
  description = "Geheugen in MB"
  type        = number
  default     = 2048
}

variable "cpu_count" {
  description = "Aantal vCPU's"
  type        = number
  default     = 2
}