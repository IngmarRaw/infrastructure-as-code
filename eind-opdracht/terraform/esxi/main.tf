terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    esxi = {
      source  = "josenk/esxi"
      version = "~> 1.10"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_hostssl  = var.esxi_hostssl
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

resource "esxi_guest" "vm" {
  guest_name     = var.vm_name
  disk_store     = var.disk_store
  boot_disk_size = var.boot_disk_size

  memsize  = var.memory_mb
  numvcpus = var.cpu_count

  guestos = "ubuntu-64"

  ovf_source = var.ovf_source

  network_interfaces {
    virtual_network = var.virtual_network
  }

  guestinfo = {
    "metadata" = base64encode(templatefile("${path.module}/metadata.tftpl", {
      vm_name = var.vm_name
    }))
    "metadata.encoding" = "base64"

    "userdata" = base64encode(templatefile("${path.module}/cloudinit.tftpl", {
      username       = var.admin_username
      ssh_public_key = local.ssh_public_key
    }))
    "userdata.encoding" = "base64"
  }
}