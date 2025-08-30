
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
  sku_name            = "F1"
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
      docker_image     = "docker.n8n.io/n8nio/n8n"
      docker_image_tag = "latest"
    }
    always_on           = true
    minimum_tls_version = "1.2"
    use_32_bit_worker   = true # When using a F1 tier app service plan. Free or Shared tiers do not have a 64 bit option.
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "true"
    N8N_BASIC_AUTH_ACTIVE               = "true"
    N8N_BASIC_AUTH_USER                 = "admin"
    N8N_BASIC_AUTH_PASSWORD             = var.n8n_admin_password
    N8N_HOST                            = "0.0.0.0"
    N8N_PORT                            = "5678"
    N8N_ENCRYPTION_KEY                  = ""
    PROTOCOL_N8N                        = "https"
    WEBHOOK_URL                         = ""
    HOST_N8N                            = ""
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
