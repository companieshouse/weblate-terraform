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


#---------------------------------------------------------------------
# EFS resources
#---------------------------------------------------------------------
resource "aws_efs_file_system" "weblate" {
  creation_token   = "${local.weblate_tag}-shared-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "${local.weblate_tag}-efs"
  }
}

resource "aws_efs_access_point" "weblate_accp" {
  file_system_id = aws_efs_file_system.weblate.id

  root_directory {
    path = "/app"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }
}
// security group in EFS VPC
resource "aws_security_group" "efs_sg" {
  name        = local.efs_sg_name
  vpc_id      = data.aws_vpc.efs_vpc.id
  description = "EFS security group EFS VPC"
}
// security group in APP VPC
resource "aws_security_group" "efs_sg_app_vpc" {
  name        = local.efs_sg_name
  vpc_id      = data.aws_vpc.vpc.id
  description = "EFS security group APP VPC"
}

resource "aws_efs_mount_target" "weblate_efs_vpc_mounts" {
  for_each        = toset(local.efs_subnet_ids)
  file_system_id  = aws_efs_file_system.weblate.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}


# Allow access from ECS VPC
resource "aws_vpc_security_group_ingress_rule" "efs_ingress" {
  security_group_id = aws_security_group.efs_sg.id
  from_port         = 2049
  to_port           = 2049
  ip_protocol       = "tcp"
  cidr_ipv4         = data.aws_subnets.application.cidr_blocks
  description       = "Allow NFS access from weblate ECS"
}
