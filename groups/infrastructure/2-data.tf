# lookup at the rds instance created in the previous phase
data "aws_db_instance" "weblate" {
  db_instance_identifier = local.rds_identifier
}

# lookup at the elasticache instance created in the previous phase
data "aws_elasticache_replication_group" "weblate" {
  replication_group_id = local.elasticache_id
}
