resource "aws_security_group" "redis_sg" {
  name        = var.config.redis_sg_name
  vpc_id      = var.config.vpc_id
  description = "Allow weblate ECS tasks to access Redis"
}

# ECS ingress rules are added while provisioning the ECS services

# # Add 1 single egress rule
# resource "aws_security_group_rule" "redis_egress_all" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.redis_sg.id
#   description       = "Allow all outbound traffic"
# }

resource "aws_elasticache_subnet_group" "weblate" {
  name       = "${var.config.environment}-weblate-redis-subnets"
  subnet_ids = var.config.application_subnet_ids
}

resource "aws_elasticache_replication_group" "weblate" {
  description                = "Weblate Redis"
  replication_group_id       = var.config.redis_id
  automatic_failover_enabled = false
  node_type                  = "cache.t3.small"
  num_cache_clusters         = 1
  subnet_group_name          = aws_elasticache_subnet_group.weblate.name
  security_group_ids         = [aws_security_group.redis_sg.id]
  engine                     = "redis"
}
