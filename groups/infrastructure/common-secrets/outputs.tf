# ------------------------------------------------------------------------------
# PostgreSQL Outputs
# ------------------------------------------------------------------------------
output "db_master_username" {
  value = local.service_secrets["psql_master_user"]
  sensitive = true
}

output "db_master_password" {
  value = local.service_secrets["psql_master_password"]
  sensitive = true
}

output "db_username" {
  value = local.service_secrets["postgres_user"]
  sensitive = true
}

output "db_password" {
  value = local.service_secrets["postgres_password"]
  sensitive = true
}

# ------------------------------------------------------------------------------
# Stack and service secrets Outputs
# ------------------------------------------------------------------------------
output "global_secret_list" {
  value = local.global_secret_list
  sensitive = true
}

output "service_secret_list" {
  value = local.service_secret_list
  sensitive = true
}

output "service_secrets_sanitised" {
  value = local.service_secrets_sanitised
  sensitive = true
}

output "ssm_global_version_map" {
  value = local.ssm_global_version_map
  sensitive = true
}

output "ssm_service_version_map" {
  value = local.ssm_service_version_map
  sensitive = true
}
