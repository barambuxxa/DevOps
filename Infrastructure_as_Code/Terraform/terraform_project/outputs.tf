output "vm_detalis" {
  description = "Details of all created VMs"
  value = {
    k8sMaster = {
      id   = module.k8sMaster.vm_id
      name = module.k8sMaster.VM_name
      ip   = "192.168.0.88"
      node = module.k8sMaster.target_node
    }

    workNode1 = {
      id   = module.workNode1.vm_id
      name = module.workNode1.VM_name
      ip   = "192.168.0.87"
      node = module.workNode1.target_node
    }

    workNode2 = {
      id   = module.workNode2.vm_id
      name = module.workNode2.VM_name
      ip   = "192.168.0.86"
      node = module.workNode2.target_node
    }

    JenkinsServer = {
      id   = module.JenkinsServer.vm_id
      name = module.JenkinsServer.VM_name
      ip   = "192.168.0.85"
      node = module.JenkinsServer.target_node
    }

    JenkinsAgent = {
      id   = module.JenkinsAgent.vm_id
      name = module.JenkinsAgent.VM_name
      ip   = "192.168.0.83"
      node = module.JenkinsAgent.target_node
    }

    JenkinsServer = {
      id   = module.JenkinsServer.vm_id
      name = module.JenkinsServer.VM_name
      ip   = "192.168.0.84"
      node = module.JenkinsServer.target_node
    }
  }
}

output "ssh_connections" {
  description = "SSH connection commands for all VMs"
  value = {
    k8sMaster     = "ssh ${var.vm_username}@192.168.0.88"
    workNode1     = "ssh ${var.vm_username}@192.168.0.87"
    workNode2     = "ssh ${var.vm_username}@192.168.0.86"
    JenkinsServer = "ssh ${var.vm_username}@192.168.0.85"
    JenkinsAgent  = "ssh ${var.vm_username}@192.168.0.83"
    AnsibleServer = "ssh ${var.vm_username}@192.168.0.84"  

}
}
