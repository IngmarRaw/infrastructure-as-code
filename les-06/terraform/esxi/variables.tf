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

variable "vm_name" {
  description = "Naam van de ESXi VM"
  type        = string
  default     = "les06-esxi-vm"
}

variable "disk_store" {
  description = "ESXi datastore"
  type        = string
  sensitive   = true
}

variable "virtual_network" {
  description = "ESXi port group / virtual network"
  type        = string
  sensitive   = true
}

variable "ovf_source" {
  description = "Pad of URL naar Ubuntu cloud image OVF/OVA"
  type        = string
  sensitive   = true
}

variable "boot_disk_size" {
  description = "Bootdisk grootte in GB"
  type        = number
  default     = 20
}

variable "memory_mb" {
  description = "RAM in MB"
  type        = number
  default     = 2048
}

variable "cpu_count" {
  description = "Aantal vCPU's"
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "Admin gebruiker voor de ESXi VM"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key content voor de ESXi VM"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_public_key_path" {
  description = "Lokaal pad naar SSH public key voor handmatig testen"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}