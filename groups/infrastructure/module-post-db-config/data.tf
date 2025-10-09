data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = "${var.config.name_prefix}-cluster"
}

data "aws_iam_role" "ecs_cluster_iam_role" {
  name = "${var.config.name_prefix}-ecs-task-execution-role"
}

data "aws_lb" "rand_lb" {
  name = var.config.lb_name
}

data "aws_lb_listener" "rand_lb_listener" {
  load_balancer_arn = data.aws_lb.rand_lb.arn
  port              = 443
}
