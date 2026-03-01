variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "cp2"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "switzerlandnorth"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_admin_username" {
  description = "Name of the admin user of the virtual machine"
  type        = string
  default     = "adminUser"
}