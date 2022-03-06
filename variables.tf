variable "resource_group_name" {
  description = "Name of the resource group in which the resources will be created"
  default     = "myResourceGroup"
}

variable "location" {
  default = "koreacentral"
  description = "Location where resources will be created"
}

variable "vm_sku" {
  default = "Standard_F1s"
  description = "Virtual machine SKU"
}

variable "vm_count" {
  default = 4
  description = "Virtual machine count"
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    environment = "mhddos"
  }
}
