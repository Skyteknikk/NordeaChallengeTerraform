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

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "backend_address_pool_id" {
  type = string
}

variable "custom_data_path" {
  type = string
}

variable "tags" {
  type = map(string)
}