# ------------------------------------------------------------------------------
# Infra Outputs
# ------------------------------------------------------------------------------
output "vpc_name" {
  value     = local.stack_secrets["vpc_name"]
}
output "application_subnet_pattern" {
  value     = local.stack_secrets["application_subnet_pattern"]
}
# ------------------------------------------------------------------------------
# PostgreSQL Outputs
# ------------------------------------------------------------------------------
output "db_master_username" {
  value     = local.service_secrets["psql_master_user"]
  sensitive = true
}

output "db_master_password" {
  value     = local.service_secrets["psql_master_password"]
  sensitive = true
}

output "db_username" {
  value     = local.service_secrets["postgres_user"]
  sensitive = true
}

output "db_password" {
  value     = local.service_secrets["postgres_password"]
  sensitive = true
}

