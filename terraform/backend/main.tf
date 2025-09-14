terraform {
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
}

provider "azurerm" {
  features {}
}

resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "backend_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    purpose     = "terraform-backend"
    environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_account" "backend_storage" {
  name                            = "${var.storage_account_prefix}${random_string.storage_suffix.result}"
  resource_group_name             = azurerm_resource_group.backend_rg.name
  location                        = azurerm_resource_group.backend_rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
  }

  tags = {
    purpose     = "terraform-backend"
    environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "backend_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.backend_storage.name
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}