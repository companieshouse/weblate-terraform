resource "aws_security_group" "redis_sg" {
  name        = "${var.environment}-${local.whole_service_name}-redis-sg"
  description = "Allow weblate ECS tasks to access Redis"
  vpc_id      = data.aws_vpc.vpc.id
}

# Ingress rules for each weblate ECS SG into Redis
resource "aws_security_group_rule" "redis_from_ecs" {
  for_each = merge(
    module.ecs_services,
    module.ecs-service-celery-beat
  )
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = each.value.security_group_id
  security_group_id        = aws_security_group.redis_sg.id
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
  security_group_ids         = [aws_security_group.redis_sg.id]
  engine                     = "redis"
}
