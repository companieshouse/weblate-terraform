data "vault_generic_secret" "stack_secrets" {
  path = var.config.stack_secrets_path
}
data "vault_generic_secret" "service_secrets" {
  path = var.config.service_secrets_path
}
data "vault_generic_secret" "ch_development_concourse_cidrs" {
  path = "/aws-accounts/network/ch-development-private-management-cidrs"
}

data "aws_kms_key" "kms_key" {
  key_id = var.config.kms_alias
}


# retrieve all secrets for this stack using the stack path
data "aws_ssm_parameters_by_path" "secrets" {
  path = "/${var.config.name_prefix}"
}
# retrieve all global secrets for this env using global path
data "aws_ssm_parameters_by_path" "global_secrets" {
  path = "/${var.config.global_prefix}"
}


# create a list of secrets names to retrieve them in a nicer format and lookup each secret by name
data "aws_ssm_parameter" "secret" {
  for_each = toset(data.aws_ssm_parameters_by_path.secrets.names)
  name     = each.key
}
# create a list of secrets names to retrieve them in a nicer format and lookup each secret by name
data "aws_ssm_parameter" "global_secret" {
  for_each = toset(data.aws_ssm_parameters_by_path.global_secrets.names)
  name     = each.key
}
