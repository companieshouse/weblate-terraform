resource "aws_security_group" "redis_sg" {
  name        = var.config.redis_sg_name
  vpc_id      = var.config.vpc_id
  description = "Allow weblate ECS tasks to access Redis"
}

# Add shared-ECS SG to ingress rules
resource "aws_vpc_security_group_ingress_rule" "redis_ingress" {
  security_group_id            = aws_security_group.redis_sg.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_shared.id
  description                  = "Allow access from weblate ECS services"
}

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
