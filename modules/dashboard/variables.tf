
variable "vmNamesByResourceGroups" {
  description = "Key is a resource group name, values is a list of vm names"
  type = map(list(string))
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
}
