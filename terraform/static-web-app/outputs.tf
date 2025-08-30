output "static_web_app_name" {
  description = "Name of the Static Web App"
  value       = azurerm_static_web_app.dashboard.name
}

output "deployment_token" {
  description = "Deployment token for the Static Web App"
  value       = azurerm_static_web_app.dashboard.api_key
  sensitive   = true
}

output "default_host_name" {
  description = "Default hostname of the Static Web App"
  value       = azurerm_static_web_app.dashboard.default_host_name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.static_web_app.name
}