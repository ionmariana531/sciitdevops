variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "test-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
  default     = "test-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/24"]  # Mărimea mai mică pentru test
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "test-subnet"
}

variable "subnet_address_prefix" {
  description = "Subnet address prefix"
  type        = string
  default     = "10.0.0.0/25"  # Adresă mai mică pentru test
}

variable "nsg_name" {
  description = "Network Security Group name"
  type        = string
  default     = "test-nsg"
}

variable "public_ip_name" {
  description = "Public IP name"
  type        = string
  default     = "test-public-ip"
}

variable "nic_name" {
  description = "Network Interface name"
  type        = string
  default     = "test-nic"
}

variable "vm_name" {
  description = "Virtual Machine name"
  type        = string
  default     = "test-vm"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"  # Instanță mică pentru test, costuri reduse
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Path to the SSH public key"
  type        = string
  default     = "./azure.pem.pub"
}

variable "ssh_private_key" {
  description = "Path to the SSH private key"
  type        = string
  default     = "./azure.pem"
}

variable "storage_account_type" {
  description = "Storage account type for the OS disk"
  type        = string
  default     = "Standard_LRS"  # Tip de stocare mai ieftin pentru test
}

variable "disk_size_gb" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 20  # Discul mai mic pentru test
}

