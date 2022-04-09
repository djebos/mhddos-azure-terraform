output "tls_private_key" {
  value = tls_private_key.example_ssh.private_key_pem
}

data "azurerm_public_ip" "vmIps" {
  count = var.vm_count
  name                = azurerm_public_ip.myterraformpublicip[count.index].name
  resource_group_name = azurerm_resource_group.myterraformgroup.name
#  update 4 to the value form var.vm_count cause it must be static
  depends_on          = [azurerm_linux_virtual_machine.myterraformvm[4]]
}

output "instancePublicIPs" {
  value = data.azurerm_public_ip.vmIps.*.ip_address
}

output "vmNames" {
  value = azurerm_linux_virtual_machine.myterraformvm[*].name
}
output "resourceGroupName" {
  value = azurerm_resource_group.myterraformgroup.name
}