locals {
  stack_name         = "rand-pocs" # this must match the stack name the service deploys into
  name_prefix        = "${local.stack_name}-${var.environment}"
  global_prefix      = "global-${var.environment}"
  whole_service_name = "weblate"
  weblate_tag        = "${var.environment}-${local.whole_service_name}"
  rds_identifier     = "${local.weblate_tag}-postgresdb"
  elasticache_id     = "${local.weblate_tag}-elasticache"

  stack_secrets_path   = "applications/${var.aws_profile}/${var.environment}/${local.stack_name}-stack"
  service_secrets_path = "${local.stack_secrets_path}/weblate"

  kms_alias = "alias/${var.aws_profile}/environment-services-kms"
  lb_name   = "alb-randd-rand"

  vpc_name                   = local.stack_secrets["vpc_name"]
  application_subnet_ids     = data.aws_subnets.application.ids
  application_subnet_pattern = local.stack_secrets["application_subnet_pattern"]

  s3_bucket_name = "${var.environment}-weblate-media"
}
