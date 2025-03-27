provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "test_vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = var.vnet_address_space
}

# Subnet
resource "azurerm_subnet" "test_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test_vnet.name
  address_prefixes     = var.subnet_address_prefix
}

# Network Security Group
resource "azurerm_network_security_group" "test_nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test_nsg.name
}

# Public IP
resource "azurerm_public_ip" "test_pip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

# Network Interface
resource "azurerm_network_interface" "test_nic" {
  name                = var.nic_name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "test-ip"
    subnet_id                     = azurerm_subnet.test_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test_pip.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "test_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.test_nic.id
  network_security_group_id = azurerm_network_security_group.test_nsg.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "test_vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.test_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
    disk_size_gb         = var.disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Name = var.vm_name
  }
}

# Output Public IP
output "test_vm_public_ip" {
  description = "Public IP of the test VM"
  value       = azurerm_public_ip.test_pip.ip_address
}

# Ansible Playbook Provisioner
resource "null_resource" "ansible_playbook" {
  depends_on = [azurerm_linux_virtual_machine.test_vm]

  provisioner "local-exec" {
    command = "sleep 90 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${azurerm_public_ip.test_pip.ip_address}, -u ${var.admin_username} --private-key=${var.ssh_private_key} install_k3s.yml -vv"
  }
}
