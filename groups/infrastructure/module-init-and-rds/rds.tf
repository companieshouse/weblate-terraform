# resource "aws_security_group" "rds_sg" {
#   name        = var.config.rds_sg_name
#   vpc_id      = var.config.vpc_id
#   description = "Allow Concourse and weblate ECS tasks to access RDS"
# }

# # ECS ingress rules are added while provisioning the ECS services

# # Add Concourse workers CIDR to access RDS
# resource "aws_vpc_security_group_ingress_rule" "rds_ingress_concourse" {
#   security_group_id = aws_security_group.rds_sg.id
#   from_port         = 5432
#   to_port           = 5432
#   ip_protocol       = "tcp"
#   prefix_list_id    = data.aws_ec2_managed_prefix_list.shared_services_cidrs.id
#   description       = "Allow Concourse workers to access RDS"
# }

# # # Add 1 single egress rule

# resource "aws_db_subnet_group" "weblate" {
#   name       = "${var.config.environment}-weblate-db-subnets"
#   subnet_ids = var.config.application_subnet_ids
# }
# resource "aws_db_instance" "weblate" {
#   identifier              = var.config.rds_identifier
#   engine                  = "postgres"
#   engine_version          = "17.5"
#   instance_class          = "db.t3.medium"
#   db_name                 = var.config.db_name
#   username                = var.config.db_master_username
#   password                = var.config.db_master_password
#   allocated_storage       = 20
#   storage_type            = "gp3"
#   multi_az                = true
#   db_subnet_group_name    = aws_db_subnet_group.weblate.name
#   vpc_security_group_ids  = [aws_security_group.rds_sg.id]
#   skip_final_snapshot     = true
#   backup_retention_period = 7
#   publicly_accessible     = false
# }
