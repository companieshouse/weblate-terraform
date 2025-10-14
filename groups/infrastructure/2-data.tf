# lookup at the rds instance created in the previous phase
data "aws_db_instance" "weblate" {
  db_instance_identifier = local.rds_identifier
}

# lookup at the rds/postgresql instance created in the previous phase
data "aws_security_group" "rds_sg" {
  filter {
    name   = "group-name"
    values = [local.rds_sg_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

# lookup at the elasticache/redis instance created in the previous phase
data "aws_security_group" "redis_sg" {
  filter {
    name   = "group-name"
    values = [local.redis_sg_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

# lookup at the elasticache/redis replication group instance created in the previous phase
data "aws_elasticache_replication_group" "weblate" {
  replication_group_id = local.redis_id
}
