variable "name_prefix" {
  description = "Prefix used for naming resources."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
}

variable "hub_vnet_id" {
  description = "Hub virtual network ID for spoke-to-hub peering."
  type        = string
}

variable "firewall_private_ip" {
  description = "Azure Firewall private IP used as next hop for forced egress."
  type        = string
}