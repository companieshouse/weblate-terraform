resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}-${local.whole_service_name}-rds-sg"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow weblate ECS tasks to access Postgres"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = concat([data.aws_vpc.vpc.cidr_block, "10.44.0.0/16"], local.ch_development_concourse_cidrs)
    # Allows VPC and any extra admin CIDRs (e.g., Concourse IPs)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Ingress rules for each weblate ECS SG into Postgres
# resource "aws_security_group_rule" "rds_from_ecs" {
#   for_each = merge(
#     module.ecs-services,
#     module.ecs-service-celery-beat
#   )
#   type                     = "ingress"
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   source_security_group_id = each.value.security_group_id
#   security_group_id        = aws_security_group.rds_sg.id
# }
resource "aws_db_subnet_group" "weblate" {
  name       = "${var.environment}-weblate-db-subnets"
  subnet_ids = local.application_subnet_ids
}
resource "aws_db_instance" "weblate" {
  identifier              = "${var.environment}-${local.whole_service_name}-postgresdb"
  engine                  = "postgres"
  engine_version          = "17.5"
  instance_class          = "db.t3.medium"
  db_name                 = "${var.postgres_db}"
  username                = local.db_master_username
  password                = local.db_master_password
  allocated_storage       = 20
  storage_type            = "gp3"
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.weblate.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  backup_retention_period = 7
  publicly_accessible     = false
}

# PostgreSQL provider — connects directly to RDS
provider "postgresql" {
  host            = aws_db_instance.weblate.address
  port            = 5432
  username        = local.db_master_username
  password        = local.db_master_password
  sslmode         = "require"
  superuser       = false
}

# Create Weblate DB user
resource "postgresql_role" "weblate_user" {
  name     = local.db_username
  login    = true
  password = local.db_password
}

# Schema ownership
resource "postgresql_schema" "public_schema" {
  name  = "public"
  owner = postgresql_role.weblate_user.name
  database = "${var.postgres_db}"
}

# Privileges on schema, tables, sequences, functions
resource "postgresql_grant" "weblate_schema_usage" {
  database    = "${var.postgres_db}"
  role        = postgresql_role.weblate_user.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_grant" "weblate_tables" {
  database    = "${var.postgres_db}"
  role        = postgresql_role.weblate_user.name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_grant" "weblate_sequences" {
  database    = "${var.postgres_db}"
  role        = postgresql_role.weblate_user.name
  schema      = "public"
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
}

# Default privileges for future tables/sequences/functions
resource "postgresql_default_privileges" "weblate_defaults" {
  database    = "${var.postgres_db}"
  role        = postgresql_role.weblate_user.name
  schema      = "public"
  owner       = postgresql_role.weblate_user.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}
