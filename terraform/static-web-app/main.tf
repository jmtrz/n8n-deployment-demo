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
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstateuniqu1"
    container_name       = "tfstate"
    key                  = "static-web-app.terraform.tfstate"
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

# Static Web App
resource "azurerm_static_web_app" "dashboard" {
  name                = "swa-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.static_web_app.name
  location            = azurerm_resource_group.static_web_app.location
  sku_tier            = var.sku_tier
  sku_size            = var.sku_size

  app_settings = {
    "ENVIRONMENT" = var.environment
    "NODE_VERSION" = "18"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Optional: Custom domain (uncomment if needed)
# resource "azurerm_static_web_app_custom_domain" "dashboard" {
#   static_web_app_id = azurerm_static_web_app.dashboard.id
#   domain_name       = var.custom_domain
#   validation_type   = "cname-delegation"
# }

# Application Insights for monitoring
resource "azurerm_application_insights" "dashboard" {
  name                = "ai-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.static_web_app.location
  resource_group_name = azurerm_resource_group.static_web_app.name
  application_type    = "web"
  retention_in_days   = var.retention_days

  tags = var.tags
}

# Log Analytics Workspace for Application Insights
resource "azurerm_log_analytics_workspace" "dashboard" {
  name                = "law-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.static_web_app.location
  resource_group_name = azurerm_resource_group.static_web_app.name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days

  tags = var.tags
}

# Connect Application Insights to Log Analytics
resource "azurerm_application_insights" "dashboard_with_workspace" {
  name                = "ai-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.static_web_app.location
  resource_group_name = azurerm_resource_group.static_web_app.name
  workspace_id        = azurerm_log_analytics_workspace.dashboard.id
  application_type    = "web"
  retention_in_days   = var.retention_days

  tags = var.tags
}

# Optional: Storage account for additional assets
resource "azurerm_storage_account" "dashboard_assets" {
  count                    = var.create_storage ? 1 : 0
  name                     = "st${var.project_name}${var.environment}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.static_web_app.name
  location                 = azurerm_resource_group.static_web_app.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }

  tags = var.tags
}

# Optional: CDN Profile for better performance
resource "azurerm_cdn_profile" "dashboard" {
  count               = var.create_cdn ? 1 : 0
  name                = "cdn-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.static_web_app.location
  resource_group_name = azurerm_resource_group.static_web_app.name
  sku                 = "Standard_Microsoft"

  tags = var.tags
}

resource "azurerm_cdn_endpoint" "dashboard" {
  count               = var.create_cdn ? 1 : 0
  name                = "cdn-endpoint-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  profile_name        = azurerm_cdn_profile.dashboard[0].name
  location            = azurerm_resource_group.static_web_app.location
  resource_group_name = azurerm_resource_group.static_web_app.name
  origin_host_header  = azurerm_static_web_app.dashboard.default_host_name

  origin {
    name      = "primary"
    host_name = azurerm_static_web_app.dashboard.default_host_name
  }

  delivery_rule {
    name  = "HTTPSRedirect"
    order = 1

    request_scheme_condition {
      operator     = "Equal"
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
    }
  }

  tags = var.tags
}