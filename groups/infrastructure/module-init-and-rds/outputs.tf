output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}

output "redis_security_group_id" {
  value = aws_security_group.redis_sg.id
}

output "ecs_shared_security_group_id" {
  value = aws_security_group.ecs_shared.id
}
