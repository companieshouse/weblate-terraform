# This is a common 'main' code used by more phases (mainly to source secrets from vault)
module "common_secrets" {
  source = "./module-secrets"
  config = {
    environment        = var.environment
    ssm_version_prefix = var.ssm_version_prefix

    name_prefix        = local.name_prefix
    global_prefix      = local.global_prefix
    whole_service_name = local.whole_service_name

    stack_secrets_path   = local.stack_secrets_path
    service_secrets_path = local.service_secrets_path
    kms_alias            = local.kms_alias
  }
}
