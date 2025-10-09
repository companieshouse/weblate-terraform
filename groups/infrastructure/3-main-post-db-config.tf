// This triggers the 3rd phase (to deploy remaining resources, mainly ECS)
module "post_db_config" {
  source = "./post-db-config"
  config = {
    environment               = var.environment
    name_prefix               = local.name_prefix
    weblate_tag               = local.weblate_tag
    whole_service_name        = local.whole_service_name
    service_secrets_sanitised = module.common_secrets.service_secrets_sanitised
    lb_name                   = local.lb_name
    ecs_service_configs       = local.ecs_service_configs
    ecs_security_group_ids    = local.ecs_security_group_ids
    application_subnet_ids    = local.application_subnet_ids
  }
}
