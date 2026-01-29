output "vm_id" {
  description = "ID create VM"
  value       = proxmox_vm_qemu.vm.id
}

output "VM_name" {
  description = "VM Name"
  value       = proxmox_vm_qemu.vm.name
}

output "target_node" {
  description = "Targer Node"
  value       = proxmox_vm_qemu.vm.target_node
}
