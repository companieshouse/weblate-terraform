locals {
  stack_name         = "rand-pocs" # this must match the stack name the service deploys into
  name_prefix        = "${local.stack_name}-${var.environment}"
  global_prefix      = "global-${var.environment}"
  whole_service_name = "weblate"
  weblate_tag        = "${var.environment}-${local.whole_service_name}"

  stack_secrets_path   = "applications/${var.aws_profile}/${var.environment}/${local.stack_name}-stack"
  service_secrets_path = "${local.stack_secrets_path}/weblate"

  kms_alias = "alias/${var.aws_profile}/environment-services-kms"
  lb_name   = "alb-randd-rand"

  vpc_name                   = module.common_secrets.vpc_name
  application_subnet_ids     = data.aws_subnets.application.ids
  application_subnet_pattern = module.common_secrets.application_subnet_pattern

  // EFS should stay in the same VPC, but in cidev the DNS config doesn't allow that (INC0527374)
  efs_vpc_name       = var.environment == "cidev" ? local.vpc_name : "Management"
  efs_subnet_ids     = data.aws_subnets.efs_subnets.ids
  efs_subnet_pattern = var.environment == "cidev" ? local.application_subnet_pattern : "dev-management-private-*"

  # rds
  rds_identifier = "${local.weblate_tag}-postgresdb"
  rds_sg_name    = "${local.weblate_tag}-rds-sg"

  # redis
  redis_id      = "${local.weblate_tag}-redis"
  redis_sg_name = "${local.weblate_tag}-redis-sg"

  # efs
  efs_sg_name = "${local.weblate_tag}-efs-sg"

  # ecs
  ecs_shared_sg_name = "${local.weblate_tag}-ecs-shared-sg"

  # s3 bucket
  s3_bucket_name = "${var.environment}-weblate-media"
  s3_policy_name = "${local.weblate_tag}-s3media-policy"

}
