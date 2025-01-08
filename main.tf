terraform {
  required_providers {
    opnsense = {
      version = "0.11.0"
      source  = "browningluke/opnsense"
    }
    macaddress = {
      version = "0.3.2"
      source  = "ivoronin/macaddress"
    }
  }
}

provider "opnsense" {
  uri            = "https://192.168.1.1"
  api_key        = var.opnsense_key
  api_secret     = var.opnsense_secret
  allow_insecure = true
}

resource "opnsense_kea_subnet" "k8_subnet" {
  subnet = var.subnet_id
  description = var.subnet_desc
  
  pools = [
    var.subnet_poll
  ]

}

resource "opnsense_kea_reservation" "k8-admin-reservation" {
  subnet_id = data.opnsense_kea_subnet.k8_subnet.id

  ip_address  = var.ip
  mac_address = macaddress.k8_admin.address

  description = "k8 admin"
}

resource "proxmox_vm_qemu" "k8-admin" {
  depends_on = [
    macaddress.k8_admin,
    opnsense_kea_reservation.k8-admin-reservation,
  ]

  name             = "k8-admin"
  desc             = "K8 Admin"
  count            = 1
  vmid             = var.vmid
  clone            = "debian"
  full_clone       = true
  cores            = 4
  memory           = 4096
  target_node      = var.proxmox_node
  agent            = 1
  boot             = "order=scsi0"
  scsihw           = "virtio-scsi-single"
  vm_state         = "running"
  automatic_reboot = true

  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "16G"
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id      = 1
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr = macaddress.k8_admin.address
  }

  os_type       = "cloud-init"
  cicustom      = "user=local:snippets/debian.yml"
  ipconfig0     = "ip=${var.ip}"
  agent_timeout = 120

  connection {
    type        = "ssh"
    user        = "debian"
    private_key = file("~/.ssh/id_rsa")
    host        = self.ssh_host
    port        = self.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
}


