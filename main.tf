# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = var.tags

}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  count = var.vm_count
  name                         = "instance${count.index}"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.myterraformgroup.name
  allocation_method            = "Dynamic"

  tags = var.tags
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "sshNetworkSecurityGroup"
  location            =  var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  count = var.vm_count
  name                      = "instance${count.index}${var.location}NIC"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "NicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip[count.index].id
  }

  tags = var.tags
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  count = var.vm_count
  network_interface_id      = azurerm_network_interface.myterraformnic[count.index].id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
#resource "random_id" "randomId" {
#  keepers = {
#     Generate a new ID only when a new resource group is defined
#    resource_group = azurerm_resource_group.myterraformgroup.name
#  }
#
#  byte_length = 8
#}

# Create storage account for boot diagnostics
#resource "azurerm_storage_account" "mystorageaccount" {
#  name                        = "diag${random_id.randomId.hex}"
#  resource_group_name         = azurerm_resource_group.myterraformgroup.name
#  location                    = var.location
#  account_tier                = "Standard"
#  account_replication_type    = "LRS"
#
#  tags = var.tags
#}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  count = var.vm_count
  name                  = "instance-${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = [azurerm_network_interface.myterraformnic[count.index].id]
  size                  = var.vm_sku
  custom_data = filebase64("cloud-init.yaml")

  os_disk {
    name              = "instance${count.index}Disk"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "instance${count.index}"
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username       = "azureuser"
    public_key     = tls_private_key.example_ssh.public_key_openssh
  }


#  boot_diagnostics {
#    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
#  }

  tags = var.tags
}
# Tried custom script extension as a tool for running mhddos scripts as a replacement of cloud-init. However,
# this approach works only on VM provisioning time
# thus you have to destroy and re-create VMs every time you change 'commandToExecute' attribute.
#resource "azurerm_virtual_machine_extension" "runMhddosScript" {
#  count = var.vm_count
#
#  name                 = "hostname"
#  virtual_machine_id   = azurerm_linux_virtual_machine.myterraformvm[count.index].id
#  publisher            = "Microsoft.Azure.Extensions"
#  type                 = "CustomScript"
#  type_handler_version = "2.0"
#
#  settings = <<SETTINGS
#    {
#        "commandToExecute": "sudo docker run --name mhddosProxy -d --rm ghcr.io/porthole-ascend-cinnamon/mhddos_proxy https://1.1.1.1 -t 1000 -p 1200 --rpc 2000 --http-methods GET STRESS --debug"
#    }
#SETTINGS
#
#  tags = var.tags
#}
