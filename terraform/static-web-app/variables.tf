variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "n8n-dashboard"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastasia"
}

variable "sku_tier" {
  description = "SKU tier for the Static Web App"
  type        = string
  default     = "Free"
}

variable "sku_size" {
  description = "SKU size for the Static Web App"
  type        = string
  default     = "Free"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Project     = "n8n-deployment-monitoring"
    ManagedBy   = "terraform"
  }
}