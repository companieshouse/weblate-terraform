resource "aws_security_group" "rds_sg" {
  name        = "${var.config.environment}-${var.config.whole_service_name}-rds-sg"
  vpc_id      = var.config.vpc_id
  description = "Allow weblate ECS tasks to access Postgres"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = concat([var.config.vpc_cidr_block, "10.44.0.0/16"], local.ch_development_concourse_cidrs)
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
  name       = "${var.config.environment}-weblate-db-subnets"
  subnet_ids = var.config.application_subnet_ids
}
resource "aws_db_instance" "weblate" {
  identifier              = var.config.rds_identifier
  engine                  = "postgres"
  engine_version          = "17.5"
  instance_class          = "db.t3.medium"
  db_name                 = var.config.db_name
  username                = var.config.db_master_username
  password                = var.config.db_master_password
  allocated_storage       = 20
  storage_type            = "gp3"
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.weblate.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  backup_retention_period = 7
  publicly_accessible     = false
}
