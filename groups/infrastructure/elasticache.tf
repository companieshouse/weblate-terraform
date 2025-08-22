resource "aws_security_group" "redis" {
  name        = "${var.environment}-${local.whole_service_name}-redis-sg"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow Redis from ECS tasks"

  ingress {
    from_port       = 6379
    to_port         = 6379
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

resource "aws_elasticache_subnet_group" "weblate" {
  name       = "${var.environment}-redis-subnets"
  subnet_ids = local.application_subnet_ids
}

resource "aws_elasticache_replication_group" "weblate" {
  description                = "Weblate Redis"
  replication_group_id       = "${var.environment}-${local.whole_service_name}"
  automatic_failover_enabled = false
  node_type                  = "cache.t3.small"
  num_cache_clusters         = 1
  subnet_group_name          = aws_elasticache_subnet_group.weblate.name
  security_group_ids         = [aws_security_group.redis.id]
  engine                     = "redis"
}
