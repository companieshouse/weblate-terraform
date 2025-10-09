
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.config.vpc_name]
  }
}

#Get application subnet IDs
data "aws_subnets" "application" {
  filter {
    name   = "tag:Name"
    values = [var.config.application_subnet_pattern]
  }
}
