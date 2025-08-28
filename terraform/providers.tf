terraform {
	required_version = ">= 1.0"

	required_providers {
		azurerm = {
			source  = "hashicorp/azurerm"
			version = "~> 3.0.0"
		}
	}

	backend "azurerm" {
		# Configure via environment variables or command line
		# storage_account_name = "your-storage-account"
		# container_name       = "tfstate"
		# key                  = "n8n/terraform.tfstate"
	}
}

provider "azurerm" {
	features {}
}
