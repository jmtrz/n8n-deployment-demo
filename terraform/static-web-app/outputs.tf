output "static_web_app_name" {
  description = "Name of the Static Web App"
  value       = azurerm_static_web_app.dashboard.name
}

output "static_web_app_id" {
  description = "ID of the Static Web App"
  value       = azurerm_static_web_app.dashboard.id
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

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.static_web_app.location
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.dashboard_with_workspace.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.dashboard_with_workspace.connection_string
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.dashboard.id
}

output "storage_account_name" {
  description = "Name of the storage account (if created)"
  value       = var.create_storage ? azurerm_storage_account.dashboard_assets[0].name : null
}

output "storage_account_primary_web_endpoint" {
  description = "Primary web endpoint of the storage account (if created)"
  value       = var.create_storage ? azurerm_storage_account.dashboard_assets[0].primary_web_endpoint : null
}

output "cdn_endpoint_hostname" {
  description = "CDN endpoint hostname (if created)"
  value       = var.create_cdn ? azurerm_cdn_endpoint.dashboard[0].fqdn : null
}

output "static_web_app_principal_id" {
  description = "Principal ID of the Static Web App's managed identity"
  value       = azurerm_static_web_app.dashboard.identity[0].principal_id
}