resource "aws_security_group" "rds" {
  name        = "${var.environment}-${local.whole_service_name}-rds-sg"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow Postgres from ECS tasks"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = data.aws_security_groups.weblate_ecs.ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_db_subnet_group" "weblate" {
  name       = "${var.environment}-db-subnets"
  subnet_ids = local.application_subnet_ids
}
resource "aws_db_instance" "weblate" {
  identifier              = "${var.environment}-${local.whole_service_name}-postgresdb"
  engine                  = "postgres"
  engine_version          = "17.5"
  instance_class          = "db.t3.small"
  db_name                 = "${var.postgres_db}"
  username                = local.db_master_username
  password                = local.db_master_password
  allocated_storage       = 20
  storage_type            = "gp3"
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.weblate.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  backup_retention_period = 7
  publicly_accessible     = false
}
