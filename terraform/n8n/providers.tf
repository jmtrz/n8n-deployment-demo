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
    # Configuration will be provided via init command
    # Backend will be configured using:
    # - resource_group_name  = from TF_BACKEND_RESOURCE_GROUP_NAME
    # - storage_account_name = from TF_BACKEND_STORAGE_ACCOUNT_NAME  
    # - container_name       = from TF_BACKEND_CONTAINER_NAME
    # - access_key          = from TF_BACKEND_ACCESS_KEY
    key = "main/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  # Use service principal authentication
  use_msi = false
}
