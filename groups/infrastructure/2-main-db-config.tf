// This triggers the 2nd phase (to config the RDS instance)
module "db_config" {
  source = "./module-db-config"
  config = {
    rds_identifier     = local.rds_identifier
    db_name            = var.postgres_db
    db_master_username = module.common_secrets.db_master_username
    db_master_password = module.common_secrets.db_master_password
    db_username        = module.common_secrets.db_username
    db_password        = module.common_secrets.db_password
  }
}
