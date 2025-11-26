
#Get VPC
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

#Get EFS VPC (in CIDEV it cannot be in the usual app/dev VPC)
data "aws_vpc" "efs_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.efs_vpc_name]
  }
}

#Get application subnet IDs
data "aws_subnets" "application" {
  filter {
    name   = "tag:Name"
    values = [local.application_subnet_pattern]
  }
}

#Get EFS subnet IDs
data "aws_subnets" "efs_subnets" {
  filter {
    name   = "tag:Name"
    values = [local.efs_subnet_pattern]
  }
}

data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = "${local.name_prefix}-cluster"
}

data "aws_iam_role" "ecs_cluster_iam_role" {
  name = "${local.name_prefix}-ecs-task-execution-role"
}

data "aws_lb" "rand_lb" {
  name = local.lb_name
}

data "aws_lb_listener" "rand_lb_listener" {
  load_balancer_arn = data.aws_lb.rand_lb.arn
  port              = 443
}
