module "k8sMaster" {
  source = "./modules/vm"

  vmid          = 301
  name          = "k8sMaster"
  target_node   = "pve1"
  cpu_cores     = 2
  memory        = 8192
  template_name = var.template_name
  vm_username   = var.vm_username
  ip_address    = "192.168.0.88"
  gateway       = var.gateway
  disk_size     = var.disk_size

}

module "workNode1" {
  source = "./modules/vm"

  vmid          = 302
  name          = "workNode1"
  target_node   = "pve1"
  cpu_cores     = 2
  memory        = 4096
  template_name = var.template_name
  vm_username   = var.vm_username
  ip_address    = "192.168.0.87"
  gateway       = var.gateway
  disk_size     = var.disk_size

}

module "workNode2" {
  source = "./modules/vm"

  vmid          = 303
  name          = "workNode2"
  target_node   = "pve1"
  cpu_cores     = 2
  memory        = 4096
  template_name = var.template_name
  vm_username   = var.vm_username
  ip_address    = "192.168.0.86"
  gateway       = var.gateway
  disk_size     = var.disk_size

}

module "JenkinsServer" {
  source = "./modules/vm"

  vmid          = 304
  name          = "JenkinsServer"
  target_node   = "pve1"
  cpu_cores     = 2
  memory        = 4096
  template_name = var.template_name
  vm_username   = var.vm_username
  ip_address    = "192.168.0.85"
  gateway       = var.gateway
  disk_size     = var.disk_size

}

