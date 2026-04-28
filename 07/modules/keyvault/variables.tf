variable "tags" {
  type        = map(any)
  description = "Tags"
}

variable "prefix" {
  type        = string
  description = "Prefix for naming convention"
}

variable "resource_group_name" {
  type        = string
  description = "RG name"
}
variable "location" {
  type        = string
  description = "Location"
}
variable "tenant_id" {
  type        = string
  description = "Tenant id"
}

variable "object_id" {
  type        = string
  description = "Object id"
}
