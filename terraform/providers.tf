terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  backend "azurerm" {
    # Configuration will be provided via environment variables or init command
    # resource_group_name  = var.backend_resource_group_name
    # storage_account_name = var.backend_storage_account_name
    # container_name       = var.backend_container_name
    # key                  = "n8n/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  # Use service principal authentication
  use_msi = false
}
