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

module "VMs" {
  source = "./modules/vms"
  for_each = var.locations
  resource_group_name = "${var.resource_group_name_prefix}-${each.key}"
  location = each.key
  vm_sku = var.vm_sku
  vm_count = var.vm_count
  tags = var.tags
}

module "dashboard" {
  source = "./modules/dashboard"
  tags = var.tags
  vmNamesByResourceGroups = {for rg, mod in module.VMs: mod.resourceGroupName => mod.vmNames}
}

output "rl" {
  value = module.dashboard.rl
}