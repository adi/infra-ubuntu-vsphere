terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
    }
  }
}

variable "vsphere_user" {
  type = string
}
variable "vsphere_password" {
  type = string
  sensitive = true
}
variable "vsphere_server" {
  type = string
}
variable "vsphere_datastore_name" {
  type = string
}
variable "vsphere_datacenter_name" {
  type = string
}
variable "vsphere_cluster_name" {
  type = string
}
variable "vsphere_network_name" {
  type = string
}
variable "vsphere_folder_name" {
  type = string
}

variable "vm_name" {
  type = string
}
variable "vm_domain" {
  type = string
}
variable "vm_ip" {
  type = string
}
variable "vm_netmask" {
  type = number
}
variable "vm_gateway" {
  type = string
}
variable "vm_cpus" {
  type = number
}
variable "vm_ram_mb" {
  type = number
}
variable "vm_disk_gb" {
  type = number
}

variable "vm_initial_user" {
  type = string
}
variable "vm_initial_password" {
  type = string
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter_name
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = "ubuntu2204_template"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere_folder_name
  
  num_cpus         = var.vm_cpus
  memory           = var.vm_ram_mb
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label = "disk0"
    size             = var.vm_disk_gb
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = var.vm_name
        domain    = "localdomain"
      }
      network_interface {
        ipv4_address = var.vm_ip
        ipv4_netmask = var.vm_netmask
      }
      ipv4_gateway = var.vm_gateway
    }
  }
  provisioner "remote-exec" {
    connection {
      host = var.vm_ip
      user = var.vm_initial_user
      password = var.vm_initial_password
    }
    inline = [
      "echo ${var.vm_initial_password} | sudo -S growpart /dev/sda 2",
      "sudo resize2fs /dev/sda2"
    ]
  }
}

