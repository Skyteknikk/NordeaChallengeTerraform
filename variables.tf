#############################
# VARIABLES WITH VALIDATION
#############################

variable "location" {
  type    = string
  default = "westeurope"

  validation {
    condition     = contains(["westeurope", "northeurope"], var.location)
    error_message = "Location must be westeurope or northeurope."
  }
}

variable "project" {
  type    = string
  default = "iac-webapp"
}

variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "domain_name" {
  type        = string
  description = "DNS zone name."
}

variable "app_hostname" {
  type        = string
  description = "Application FQDN."
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key."
}

variable "certificate_pfx_path" {
  type = string
}

variable "certificate_password" {
  type      = string
  sensitive = true
}