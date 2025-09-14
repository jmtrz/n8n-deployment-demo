output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.backend_rg.name
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.backend_storage.name
}

output "container_name" {
  description = "Name of the created blob container"
  value       = azurerm_storage_container.backend_container.name
}

output "storage_account_primary_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.backend_storage.primary_access_key
  sensitive   = true
}

output "backend_config_summary" {
  description = "Summary of backend configuration for GitHub secrets"
  value = {
    TF_BACKEND_RESOURCE_GROUP_NAME  = azurerm_resource_group.backend_rg.name
    TF_BACKEND_STORAGE_ACCOUNT_NAME = azurerm_storage_account.backend_storage.name
    TF_BACKEND_CONTAINER_NAME       = azurerm_storage_container.backend_container.name
    TF_BACKEND_ACCESS_KEY           = azurerm_storage_account.backend_storage.primary_access_key
  }
  sensitive = true
}