packer {
  required_plugins {
    vsphere = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/vsphere"
    }
  }
}

variable vcenter_server {
  type = string
}
variable username {
  type = string
}
variable password {
  type = string
  sensitive = true
}
variable cluster {
  type = string
}
variable datastore {
  type = string
}
variable folder {
  type = string
}
variable vm_name {
  type = string
}
variable host {
  type = string
}
variable network {
  type = string
}

variable vm_ip {
  type = string
}
variable vm_gateway {
  type = string
}
variable vm_netmask {
  type = string
}
variable vm_dns1 {
  type = string
}
variable vm_dns2 {
  type = string
}

source "vsphere-iso" "ubuntu2204_template" {
  folder               = "${var.folder}"
  vm_name              = "${var.vm_name}"

  vcenter_server       = "${var.vcenter_server}"
  username             = "${var.username}"
  password             = "${var.password}"
  datastore            = "${var.datastore}"
  cluster              = "${var.cluster}"
  insecure_connection  = true
  guest_os_type        = "ubuntu64Guest"
  host                 = "${var.host}"
  network_adapters {
    network_card = "vmxnet3"
    network = "${var.network}"
  }

  iso_checksum         = "sha256:84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f"
  iso_url              = "https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso"
  iso_paths            = ["[vmstorage2] iso/ubuntu-22.04-live-server-amd64.iso"]

  CPUs                 = 2
  RAM                  = 4096
  RAM_reserve_all      = true
  boot_command         = [
    "<wait><wait><esc><esc><esc><esc>e<wait>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "linux /casper/vmlinuz ",
    # Next line can be commented if using DHCP server
    "ip=${var.vm_ip}::${var.vm_gateway}:${var.vm_netmask}:ubuntu2204:::${var.vm_dns1}:${var.vm_dns2} ",
    "--- autoinstall<enter><wait>",
    "initrd /casper/initrd ",
    "<enter><wait>",
    "boot<enter>",
    "<enter><f10><wait>"]

  cd_files = ["${path.root}/cdrom/meta-data", "${path.root}/cdrom/user-data"]
  cd_label = "cidata"

  storage {
    disk_size             = 10240
    disk_thin_provisioned = true
  }

  ssh_username = "ubuntu"
  ssh_password = "zmn9ToZwTKLhCw.b4"
  ssh_handshake_attempts = 100
  ssh_timeout = "20m"
  ssh_port = 22
}

build {
  sources = ["source.vsphere-iso.ubuntu2204_template"]

  provisioner "shell" {
    inline = ["ls /"]
  }
}
