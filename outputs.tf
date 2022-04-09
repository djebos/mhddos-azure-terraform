output "tls_private_keys" {
  value = {
    for region, vmSet in module.VMs : region => vmSet.tls_private_key
  }
  sensitive = true
}

output "instance_public_ips_by_regions" {
  value = {
    for region, vmSet in module.VMs : region => vmSet.instancePublicIPs
  }
}