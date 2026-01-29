resource "proxmox_vm_qemu" "vm" {
  vmid        = var.vmid
  name        = var.name
  target_node = var.target_node
  agent       = 1

  cpu {
    cores   = var.cpu_cores
    sockets = 2
    type    = "host"
  }

  memory = var.memory
  boot   = "order=virtio0"
  clone  = var.template_name

  ciuser  = var.vm_username
  sshkeys = var.myssh

  cicustom  = "vendor=local:snippets/qemu-guest-agent.yml"
  ciupgrade = true
  skip_ipv6 = true
  ipconfig0 = "ip=${var.ip_address}/24,gw=${var.gateway}"

  serial {
    id = 0
  }

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          storage = "local-lvm"
          size    = var.disk_size
        }
      }
    }
  }

  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }
}

