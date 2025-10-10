# this duplicated provider setting in a submodule is one of the many terraform limitations
terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.26.0"
    }
  }
}
# PostgreSQL provider — connects directly to RDS
provider "postgresql" {
  host      = aws_db_instance.weblate.address
  port      = 5432
  username  = var.config.db_master_username
  password  = var.config.db_master_password
  sslmode   = "require"
  superuser = false
}

# Create Weblate DB user
resource "postgresql_role" "weblate_user" {
  name     = var.config.db_username
  login    = true
  password = var.config.db_password
}

# Schema ownership
resource "postgresql_schema" "public_schema" {
  database = var.config.db_name
  name     = "public"
  owner    = postgresql_role.weblate_user.name
}

# Privileges on schema, tables, sequences, functions
resource "postgresql_grant" "weblate_schema_usage" {
  database    = var.config.db_name
  role        = postgresql_role.weblate_user.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_grant" "weblate_tables" {
  database    = var.config.db_name
  role        = postgresql_role.weblate_user.name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_grant" "weblate_sequences" {
  database    = var.config.db_name
  role        = postgresql_role.weblate_user.name
  schema      = "public"
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
}

# Default privileges for future tables/sequences/functions
resource "postgresql_default_privileges" "weblate_defaults" {
  database    = var.config.db_name
  role        = postgresql_role.weblate_user.name
  schema      = "public"
  owner       = postgresql_role.weblate_user.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}
