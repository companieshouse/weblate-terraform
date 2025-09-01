terraform {
  backend "s3" {
  }
  required_version = "~> 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.18.0"
    }
  }
}

module "secrets" {
  source = "git@github.com:companieshouse/terraform-modules//aws/ecs/secrets?ref=1.0.340"

  name_prefix = "${local.whole_service_name}-${var.environment}"
  environment = var.environment
  kms_key_id  = data.aws_kms_key.kms_key.id
  secrets     = nonsensitive(local.service_secrets_sanitised)
}

# run 1st: celery-beat only (which should start before the other ECS services)
module "ecs-service-celery-beat" {
  source = "./ecs"

  # the loop will process only 1 iteration (celery-beat)
  for_each = {
    for name, cfg in local.ecs_service_configs :
    name => cfg
    if cfg.service_name == "weblate-celery-beat"
  }

  config     = each.value
  depends_on = [module.secrets]
}


# run 2nd: all others ECS
module "ecs-services" {
  source = "./ecs"

  # the loop will process all except 1 (celery-beat)
  for_each = {
    for name, cfg in local.ecs_service_configs :
    name => cfg
    if cfg.service_name != "weblate-celery-beat"
  }

  config     = each.value
  depends_on = [module.secrets, module.ecs-service-celery-beat] # <-- here the dependency which will run this after
}

resource "aws_iam_role" "ecs_task_role" {
  name = "weblate-tasks-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
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
