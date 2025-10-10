locals {
  # Secrets
  stack_secrets   = jsondecode(data.vault_generic_secret.stack_secrets.data_json)
  service_secrets = jsondecode(data.vault_generic_secret.service_secrets.data_json)

  service_secrets_sanitised = {
    for k, v in local.service_secrets :
    k => v if !contains([
      "psql_master_user",
      "psql_master_password",
    ], k)
  }

  # GLOBAL: create a map of secret name => secret arn to pass into ecs service module
  global_secrets_arn_map = {
    for sec in data.aws_ssm_parameter.global_secret :
    trimprefix(sec.name, "/${var.config.global_prefix}/") => sec.arn
  }

  # GLOBAL: create a list of secret name => secret arn to pass into ecs service module
  global_secret_list = flatten([for key, value in local.global_secrets_arn_map :
    { "name" = upper(key), "valueFrom" = value }
  ])

  # SERVICE: create a map of secret name => secret arn to pass into ecs service module
  service_secrets_arn_map = {
    for sec in module.secrets.secrets :
    trimprefix(sec.name, "/${var.config.whole_service_name}-${var.config.environment}/") => sec.arn
  }

  # SERVICE: create a list of secret name => secret arn to pass into ecs service module
  service_secret_list = flatten([for key, value in local.service_secrets_arn_map :
    { "name" = upper(key), "valueFrom" = value }
  ])

  # GLOBAL: create a map of secret name and secret version to pass into ecs service module
  ssm_global_version_map = [
    for sec in data.aws_ssm_parameter.global_secret : {
      name = "GLOBAL_${var.config.ssm_version_prefix}${replace(upper(basename(sec.name)), "-", "_")}", value = sec.version
    }
  ]

  # SERVICE: create a map of secret name and secret version to pass into ecs service module
  ssm_service_version_map = [
    for sec in module.secrets.secrets : {
      name = "${replace(upper(var.config.whole_service_name), "-", "_")}_${var.config.ssm_version_prefix}${replace(upper(basename(sec.name)), "-", "_")}", value = sec.version
    }
  ]
}
