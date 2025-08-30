terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
  
  backend "azurerm" {
    # Configuration provided via CLI arguments in GitHub Actions
  }
}

provider "azurerm" {
  features {}
}

# Generate random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group for Static Web App
resource "azurerm_resource_group" "static_web_app" {
  name     = "rg-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  location = var.location
  
  tags = var.tags
}

# Static Web App - Basic setup for demo
resource "azurerm_static_web_app" "dashboard" {
  name                = "swa-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.static_web_app.name
  location            = azurerm_resource_group.static_web_app.location
  sku_tier            = var.sku_tier
  sku_size            = var.sku_size

  tags = var.tags
}