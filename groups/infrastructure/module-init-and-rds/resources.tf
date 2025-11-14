# define 1 SG for all the ECS tasks to use when accessing EFS, RDS, Redis
resource "aws_security_group" "ecs_shared" {
  name        = var.config.ecs_shared_sg_name
  vpc_id      = var.config.vpc_id
  description = "ECS shared security group"
}

# Add an Egress rule, to the shared ECS SG, to allow udp/tcp 53
resource "aws_vpc_security_group_egress_rule" "efs_egress_dns" {
  security_group_id = aws_security_group.ecs_shared.id
  from_port         = 53
  to_port           = 53
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all egress on port 53 (any protocol) from weblate ECS SG"
}
