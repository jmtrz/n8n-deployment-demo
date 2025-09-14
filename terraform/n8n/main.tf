
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
      docker_image_name     = "n8nio/n8n:nightly"
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

    # n8n network configuration
    # N8N_HOST          = "n8n-appservice-${random_integer.suffix.result}.azurewebsites.net"
    # N8N_PORT          = "5678"
    # N8N_PROTOCOL      = "https"
    # N8N_SECURE_COOKIE = "true"

    HOST_N8N                            = "n8n-appservice-${random_integer.suffix.result}.azurewebsites.net"
    PORT_N8N                            = "5678"
    PROTOCOL_N8N                        = "https"
    WEBHOOK_URL                         = "n8n-appservice-${random_integer.suffix.result}.azurewebsites.net"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "true"

    # PostgreSQL Database Configuration
    DB_TYPE                = "postgresdb"
    DB_POSTGRESDB_HOST     = azurerm_postgresql_flexible_server.n8n_postgres.fqdn
    DB_POSTGRESDB_PORT     = "5432"
    DB_POSTGRESDB_DATABASE = azurerm_postgresql_flexible_server_database.n8n_database.name
    DB_POSTGRESDB_USER     = var.postgres_admin_username
    DB_POSTGRESDB_PASSWORD = var.postgres_admin_password
    DB_POSTGRESDB_SCHEMA   = "public"
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

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "n8n_postgres" {
  name                = "n8n-postgres-${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.n8n_rg.name
  location            = azurerm_resource_group.n8n_rg.location

  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password

  sku_name   = "B_Standard_B1ms" # Burstable B1ms tier
  storage_mb = 32768             # 32GB storage (minimum for Flexible Server)
  version    = "13"              # PostgreSQL version

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = {
    environment = "demo"
  }
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "n8n_database" {
  name      = "n8n"
  server_id = azurerm_postgresql_flexible_server.n8n_postgres.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# PostgreSQL Firewall Rule - Allow Azure Services
resource "azurerm_postgresql_flexible_server_firewall_rule" "n8n_postgres_firewall_azure" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.n8n_postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
