variable "n8n_admin_password" {
  description = "Password for n8n admin user"
  type        = string
  sensitive   = true
}

variable "postgres_admin_username" {
  description = "Administrator username for PostgreSQL server"
  type        = string
  default     = "n8nadmin"
}

variable "postgres_admin_password" {
  description = "Administrator password for PostgreSQL server"
  type        = string
  sensitive   = true
}