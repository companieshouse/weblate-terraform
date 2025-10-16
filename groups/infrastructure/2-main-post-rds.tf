module "db_config" {
  source = "./module-db-config"
  config = {
    rds_identifier     = local.rds_identifier
    db_master_username = module.common_secrets.db_master_username
    db_master_password = module.common_secrets.db_master_password
    db_username        = module.common_secrets.db_username
    db_password        = module.common_secrets.db_password
  }
}

module "secrets" {
  source = "git@github.com:companieshouse/terraform-modules//aws/ecs/secrets?ref=1.0.340"

  name_prefix = "${local.whole_service_name}-${var.environment}"
  environment = var.environment
  kms_key_id  = module.common_secrets.kms_key_id
  secrets     = nonsensitive(module.common_secrets.service_secrets_sanitised)
}


# run 1st: celery-beat only (which should start before the other ECS services)
module "ecs-service-celery-beat" {
  source = "./module-ecs"

  # the loop will process only 1 iteration (celery-beat)
  for_each = {
    for name, cfg in local.ecs_service_configs :
    name => cfg
    if cfg.service_name == "weblate-celery-beat"
  }

  config                  = each.value
  rds_security_group_id   = data.aws_security_group.rds_sg.id   // prev. phase
  redis_security_group_id = data.aws_security_group.redis_sg.id // prev. phase
  efs_security_group_id   = aws_security_group.efs.id           // this phase

  depends_on = [module.secrets, module.db_config]
}


# run 2nd: all others ECS
module "ecs-services" {
  source = "./module-ecs"

  # the loop will process all except 1 (celery-beat)
  for_each = {
    for name, cfg in local.ecs_service_configs :
    name => cfg
    if cfg.service_name != "weblate-celery-beat"
  }

  config                  = each.value
  rds_security_group_id   = data.aws_security_group.rds_sg.id   // prev. phase
  redis_security_group_id = data.aws_security_group.redis_sg.id // prev. phase
  efs_security_group_id   = aws_security_group.efs.id           // this phase

  depends_on = [module.ecs-service-celery-beat] # <-- here the dependency which will run this after
}
