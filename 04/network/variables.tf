variable "tags" {
  type        = map(any)
  description = "Map with tags"
}

variable "prefix" {
  type        = string
  description = "Prefix for naming"
}

variable "resource_group_name" {
  type = string
}
