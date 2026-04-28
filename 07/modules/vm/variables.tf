variable "tags" {
  type        = map(any)
  description = "Map with tags"
}

variable "prefix" {
  type        = string
  description = "Prefix for naming"
}

variable "resource_group_name" {
  type        = string
  description = "Rg name"
}

variable "location" {
  type        = string
  description = "Location"
}

variable "admin_password" {
  type        = string
  description = "Admin password for vm"
}
