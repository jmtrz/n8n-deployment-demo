variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "n8n-dashboard"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "sku_tier" {
  description = "SKU tier for the Static Web App"
  type        = string
  default     = "Free"
  
  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "SKU tier must be either Free or Standard."
  }
}

variable "sku_size" {
  description = "SKU size for the Static Web App"
  type        = string
  default     = "Free"
  
  validation {
    condition     = contains(["Free", "Standard"], var.sku_size)
    error_message = "SKU size must be either Free or Standard."
  }
}

variable "custom_domain" {
  description = "Custom domain name for the static web app"
  type        = string
  default     = null
}

variable "retention_days" {
  description = "Number of days to retain logs and telemetry data"
  type        = number
  default     = 30
  
  validation {
    condition     = var.retention_days >= 30 && var.retention_days <= 730
    error_message = "Retention days must be between 30 and 730."
  }
}

variable "create_storage" {
  description = "Whether to create additional storage account for assets"
  type        = bool
  default     = false
}

variable "create_cdn" {
  description = "Whether to create CDN for better performance"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "n8n-deployment-monitoring"
    ManagedBy   = "terraform"
    Purpose     = "static-web-app"
  }
}