resource "aws_efs_file_system" "weblate" {
  creation_token   = "weblate-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "${var.config.weblate_tag}-efs"
  }
}

resource "aws_security_group" "efs" {
  name        = "weblate_efs_sg"
  vpc_id      = var.config.vpc_id
  description = "EFS security group"

  dynamic "ingress" {
    for_each = toset(var.config.ecs_security_group_ids)
    content {
      from_port       = 2049
      to_port         = 2049
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_efs_mount_target" "weblate" {
  for_each        = { for subnet_id in var.config.application_subnet_ids : subnet_id => subnet_id }
  file_system_id  = aws_efs_file_system.weblate.id
  subnet_id       = each.key
  security_groups = [aws_security_group.efs.id]
}
