terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

locals {
  ssh_public_key = trimspace(
    var.ssh_public_key != "" ? var.ssh_public_key : file(pathexpand(var.ssh_public_key_path))
  )
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_public_ip" "azure_vm_pip" {
  name                = "pip-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_network_interface" "azure_vm_nic" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure_vm_pip.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "azure_vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.azure_vm_nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  custom_data = base64encode(templatefile("${path.module}/cloudinit.tftpl", {
    admin_username = var.admin_username
    ssh_public_key = local.ssh_public_key
  }))

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = var.tags
}