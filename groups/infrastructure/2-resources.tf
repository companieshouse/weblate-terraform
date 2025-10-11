#---------------------------------------------------------------------
# ECS resources
#---------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_role" {
  name = "weblate-tasks-exec-role"

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


#---------------------------------------------------------------------
# EFS resources
#---------------------------------------------------------------------
resource "aws_efs_file_system" "weblate" {
  creation_token   = "weblate-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "${local.weblate_tag}-efs"
  }
}

resource "aws_security_group" "efs" {
  name        = "${local.weblate_tag}-efs-sg"
  vpc_id      = data.aws_vpc.vpc.id
  description = "EFS security group"
}
resource "aws_security_group_rule" "efs_from_ecs" {
  for_each = toset(ecs_security_group_ids)

  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = each.value
  description              = "Allow NFS access from ECS service SG ${each.value}"
}

resource "aws_security_group_rule" "efs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs.id
  description       = "Allow all outbound traffic"
}


resource "aws_efs_mount_target" "weblate" {
  for_each        = { for subnet_id in local.application_subnet_ids : subnet_id => subnet_id }
  file_system_id  = aws_efs_file_system.weblate.id
  subnet_id       = each.key
  security_groups = [aws_security_group.efs.id]
}
