# propagates the Fargate security group ID from the ecs-service module
output "fargate_security_group_id" {
  value = module.ecs-service.fargate_security_group_id
}

output "ecs_name" {
  value = var.config.service_name
}
