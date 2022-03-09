output "tls_private_key" {
  value = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}

data "azurerm_public_ip" "vmIps" {
  count = var.vm_count
  name                = azurerm_public_ip.myterraformpublicip[count.index].name
  resource_group_name = azurerm_resource_group.myterraformgroup.name
}

output "instancePublicIPs" {
  value = data.azurerm_public_ip.vmIps.*.ip_address
}