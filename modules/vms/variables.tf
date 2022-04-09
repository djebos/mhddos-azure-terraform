
variable "location" {
  description = "Location where resources will be created"
}

variable "resource_group_name" {
  description = "Name of the resource group in which the resources will be created"
}

variable "vm_sku" {
  description = "Virtual machine SKU"
}

variable "vm_count" {
  description = "Virtual machine count"
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
}
