
variable "locations" {
  type = set(string)
  default = ["koreacentral"]
  description = "Locations where resources will be created"
}

variable "resource_group_name_prefix" {
  description = "Prefix of the resource group in which the resources will be created"
  default     = "mhddos"
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
