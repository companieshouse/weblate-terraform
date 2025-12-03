# This triggers the 1st phase (to create some first resources, mainly RDS)
module "init_and_rds" {
  source = "./module-init-and-rds"
  config = {
    environment                = var.environment
    whole_service_name         = local.whole_service_name
    weblate_tag                = local.weblate_tag
    vpc_id                     = data.aws_vpc.vpc.id
    concourse_cidrs            = module.common_secrets.concourse_cidrs
    application_subnet_pattern = local.application_subnet_pattern
    application_subnet_ids     = local.application_subnet_ids
    efs_vpc_cidrs              = data.aws_vpc.efs_vpc.cidr_block
    /* ecs */
    ecs_shared_sg_name = local.ecs_shared_sg_name
    /* s3 */
    s3_bucket_name = local.s3_bucket_name
    s3_policy_name = local.s3_policy_name
    /* rds */
    db_name            = var.postgres_db
    rds_identifier     = local.rds_identifier
    rds_sg_name        = local.rds_sg_name
    db_master_username = module.common_secrets.db_master_username
    db_master_password = module.common_secrets.db_master_password
    /* elasticache/redis */
    redis_id      = local.redis_id
    redis_sg_name = local.redis_sg_name
  }
}
