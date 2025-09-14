variable "resource_group_name" {
  description = "Name of the resource group for the Terraform backend"
  type        = string
  default     = "n8n-terraform-state-rg"
}

variable "location" {
  description = "Azure region for the backend resources"
  type        = string
  default     = "West US 2"
}

variable "storage_account_prefix" {
  description = "Prefix for the storage account name (will have random suffix)"
  type        = string
  default     = "n8ntfstate"

  validation {
    condition     = can(regex("^[a-z0-9]{3,15}$", var.storage_account_prefix))
    error_message = "Storage account prefix must be 3-15 characters long and contain only lowercase letters and numbers."
  }
}

variable "container_name" {
  description = "Name of the blob container for storing Terraform state"
  type        = string
  default     = "tfstate"
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string
  default     = "demo"
}