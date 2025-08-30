
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "n8n_rg" {
  name     = "n8n-resource-group-${random_integer.suffix.result}"
  location = "southeastasia"
  tags = {
    environment = "demo"
  }
}

resource "azurerm_service_plan" "n8n_plan" {
  name                = "n8n-appservice-plan-${random_integer.suffix.result}"
  location            = azurerm_resource_group.n8n_rg.location
  resource_group_name = azurerm_resource_group.n8n_rg.name
  os_type             = "Linux"
  sku_name            = "B1"
  tags = {
    environment = "demo"
  }
}

resource "azurerm_linux_web_app" "n8n_app" {
  name                = "n8n-appservice-${random_integer.suffix.result}"
  location            = azurerm_resource_group.n8n_rg.location
  resource_group_name = azurerm_resource_group.n8n_rg.name
  service_plan_id     = azurerm_service_plan.n8n_plan.id
  https_only          = true

  tags = {
    environment = "demo"
  }

  site_config {
    application_stack {
      docker_image     = "n8nio/n8n"
      docker_image_tag = "latest"
    }
    always_on           = true
    minimum_tls_version = "1.2"
    # use_32_bit_worker   = true # When using a F1 tier app service plan. Free or Shared tiers do not have a 64 bit option.
  }

  app_settings = {
    # n8n authentication
    # N8N_BASIC_AUTH_ACTIVE   = "true"
    # N8N_BASIC_AUTH_USER     = "admin"
    # N8N_BASIC_AUTH_PASSWORD = var.n8n_admin_password

    # n8n network configuration (standard variable names)
    # N8N_HOST     = "https://n8n-appservice-${random_integer.suffix.result}.azurewebsites.net/"
    # N8N_PORT     = "5678"
    # N8N_PROTOCOL = "https"

    # n8n security and URLs
    # N8N_ENCRYPTION_KEY = ""
    WEBHOOK_URL                         = "n8n-appservice-${random_integer.suffix.result}.azurewebsites.net"
    HOST_N8N                            = "n8n-appservice-${random_integer.suffix.result}.azurewebsites.net"
    PORT_N8N                            = "5678"
    PROTOCOL_N8N                        = "https"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "true"

    # Additional n8n configuration
    # N8N_SECURE_COOKIE = "true"
  }

  logs {
    application_logs {
      file_system_level = "Information"
    }

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }
}
