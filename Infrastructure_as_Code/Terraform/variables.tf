variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  sensitive   = true
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  sensitive   = true
}

variable "pm_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Skip TLS verifivation"
  type        = bool
  sensitive   = true
}

variable "template_name" {
  description = "Template name"
  type        = string
  default     = "ubuntu-2404-cloudinit-template"
}

variable "vm_username" {
  description = "VM username"
  type        = string
  default     = "sysadmin"
}

variable "gateway" {
  description = "Network gateway"
  type        = string
  default     = "192.168.0.254"
}

variable "disk_size" {
  description = "Disk size"
  type        = string
  default     = "10G"
}
