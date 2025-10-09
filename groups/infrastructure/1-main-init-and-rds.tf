// This triggers the 1st phase (to create some first resources, mainly RDS)
module "init_and_rds" {
  source = "./init-and-rds"
  config = {
    environment                = var.environment
    whole_service_name         = local.whole_service_name
    weblate_tag                = local.weblate_tag
    application_subnet_pattern = local.application_subnet_pattern
    /* s3 */
    s3_bucket_name = local.s3_bucket_name
    /* rds */
    db_name            = var.postgres_db
    rds_identifier     = local.rds_identifier
    db_master_username = module.common_secrets.db_master_username
    db_master_password = module.common_secrets.db_master_password
    /* elasticache */
    elasticache_id     = local.elasticache_id
  }
}
