/*
These are the commands which should be executed:
(Note: the DB is already provisioned in phase1)
 1) Create Weblate user
   CREATE USER cidev_weblate WITH PASSWORD '...';
 2) Connect permissions and schema usage
   GRANT CONNECT ON DATABASE weblate TO cidev_weblate;
 3) Ensure the public schema exists and is owned by our user
   ALTER SCHEMA public OWNER TO cidev_weblate;
   GRANT USAGE ON SCHEMA public TO cidev_weblate;
 4) Explicit privileges on all existing tables and sequences
   GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO cidev_weblate;
   GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO cidev_weblate;
 5) Default privileges for all future objects created in this schema
   ALTER DEFAULT PRIVILEGES IN SCHEMA public
     GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cidev_weblate;
   ALTER DEFAULT PRIVILEGES IN SCHEMA public
     GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO cidev_weblate;
   ALTER DEFAULT PRIVILEGES IN SCHEMA public
     GRANT EXECUTE ON FUNCTIONS TO cidev_weblate;
 6) make sure the user can connect and owns what it needs
   GRANT ALL PRIVILEGES ON DATABASE weblate TO cidev_weblate;
*/
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
  host      = data.aws_db_instance.weblate.address
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

# Grant database privileges
resource "postgresql_grant" "weblate_db" {
  database    = local.db_name
  role        = postgresql_role.weblate_user.name
  object_type = "database"
  privileges  = ["CONNECT", "TEMPORARY"]
}

# Schema ownership
resource "postgresql_schema" "public_schema" {
  database = local.db_name
  name     = "public"
  owner    = postgresql_role.weblate_user.name
}

# Privileges on schema, tables, sequences, functions
resource "postgresql_grant" "weblate_schema_usage" {
  database    = local.db_name
  role        = postgresql_role.weblate_user.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE"]
}


resource "postgresql_default_privileges" "weblate_tables" {
  database    = local.db_name
  schema      = "public"
  owner       = var.config.db_master_username
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  roles       = [postgresql_role.weblate_user.name]
}

resource "postgresql_default_privileges" "weblate_sequences" {
  database    = local.db_name
  schema      = "public"
  owner       = var.config.db_master_username
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
  roles       = [postgresql_role.weblate_user.name]
}

resource "postgresql_default_privileges" "weblate_functions" {
  database    = local.db_name
  schema      = "public"
  owner       = var.config.db_master_username
  object_type = "function"
  privileges  = ["EXECUTE"]
  roles       = [postgresql_role.weblate_user.name]
}
