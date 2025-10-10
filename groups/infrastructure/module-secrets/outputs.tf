# ------------------------------------------------------------------------------
# Infra Outputs
# ------------------------------------------------------------------------------
output "vpc_name" {
  value = local.stack_secrets["vpc_name"]
}
output "application_subnet_pattern" {
  value = local.stack_secrets["application_subnet_pattern"]
}
output "concourse_cidrs" {
  value = data.vault_generic_secret.ch_development_concourse_cidrs.data
}

output "global_secret_list" {
  value     = data.aws_ssm_parameter.global_secret
  sensitive = true
}
output "service_secrets_sanitised" {
  value     = local.service_secrets_sanitised
  sensitive = true
}

output "kms_key_id" {
  value = data.aws_kms_key.kms_key.id
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

