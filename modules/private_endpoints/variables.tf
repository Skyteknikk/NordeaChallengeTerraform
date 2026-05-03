variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "sql_managed_instance_id" {
  type = string
}

variable "sqlmi_private_dns_zone_id" {
  type = string
}

variable "tags" {
  type = map(string)
}