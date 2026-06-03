terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
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

resource "azurerm_public_ip" "web_pip" {
  name                = "pip-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "web_nic" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "webserver" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.web_nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  custom_data = base64encode(templatefile("${path.module}/cloudinit.tftpl", {
    username       = var.admin_username
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
}

resource "azurerm_linux_virtual_machine" "webserver" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.web_nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  custom_data = base64encode(templatefile("${path.module}/cloudinit.tftpl", {
    username       = var.admin_username
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

  tags = {
    project     = "les-05"
    opdracht   = "opdracht-2"
    role        = "webserver"
    environment = "test"
  }
}