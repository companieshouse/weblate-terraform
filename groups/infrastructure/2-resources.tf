#---------------------------------------------------------------------
# ECS resources
#---------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_role" {
  name = "${local.weblate_tag}-tasks-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# lookup for the S3 policy created in module-init-and-rds
data "aws_iam_policy" "weblate_s3_policy" {
  name = local.s3_policy_name
}
resource "aws_iam_role_policy_attachment" "ecs_task_s3" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.weblate_s3_policy.arn
}
