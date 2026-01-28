variable "vmid" {
  description = "VM ID"
  type        = number
}

variable "name" {
  description = "VM_name"
  type        = string
}

variable "target_node" {
  description = "Proxmox node name"
  type        = string
}

variable "cpu_cores" {
  description = "CPU cores"
  type        = number
}

variable "memory" {
  description = "Memory in MB"
  type        = number
}

variable "myssh" {
  description = "My public ssh key"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCbZt41XcF1BrQbZHOskTw1y7SDCWMm2Q+NerW7KRp8lN7g5pYl3JzpKrjd+vSwf7yUFwUXMzKshTKoIkcxemOWK0JlmbwKKHUoL+ZcfdfdzUTzumDW20AhONEw+dJJsCTY7lD1uzUvycQJmvIR3IJ6keWGhp3z6pLEIra9jMl37mmFbsu21au5bnz1mmtJTbvXM6dgMq3/cdv64igeOLKcuJUvy1fIzi2gzp0/SNCGlLVE5PQXjw6w2jOsOr1ueGISASRKsBJjBsh2SYutn1HueGW2rTMO5K+8dX/g9HWQK982+DkVnfqNbKDxN9hLkbtJhDhZEfC6VojvhjeZrWZOcMLFOwamwROCWy2URaTc0Je9mHo1fmf3yKSRjzyikAQ6Vd/1Pqca6KjUH1Pb9UvIfbo6ostpjW/CsnRXixCnkxT9v8+ms8OEIQATQXrxsMzBW6g8qUOTltdtlQHxvRdlrKsUcG1WO1qeUetUKYbcsOi8IIWaHEIonPNIjCaHKS0= sysadmin@rezervAnsible"
}

variable "ip_address" {
  description = "VM IP address"
  type        = string
}

variable "template_name" {
  description = "Template name"
  type        = string
}

variable "vm_username" {
  description = "VM username"
  type        = string
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "disk_size" {
  description = "Disk size"
  type        = string
}
