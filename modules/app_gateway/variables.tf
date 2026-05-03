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

variable "app_hostname" {
  type = string
}

variable "certificate_pfx_path" {
  type = string
}

variable "certificate_password" {
  type      = string
  sensitive = true
}

variable "log_analytics_id" {
  type = string
}

variable "tags" {
  type = map(string)
}