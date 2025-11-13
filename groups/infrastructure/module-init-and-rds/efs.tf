#---------------------------------------------------------------------
# EFS resources
#---------------------------------------------------------------------
resource "aws_efs_file_system" "weblate" {
  creation_token   = "${var.config.weblate_tag}-shared-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "${var.config.weblate_tag}-efs"
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

resource "aws_security_group" "efs" {
  name        = var.config.efs_sg_name
  vpc_id      = data.aws_vpc.vpc.id
  description = "EFS security group"
}

resource "aws_efs_mount_target" "weblate" {
  for_each        = toset(var.config.application_subnet_ids)
  file_system_id  = aws_efs_file_system.weblate.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

# Allow ECS access from the VPC - we cannot add just the ECS SG as they are still unkown at this point
resource "aws_security_group_rule" "efs_ingress" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.efs.id
  description       = "Allow NFS access from the VPC"
}
