# Define all hardcoded local variable and local variables looked up from data resources
locals {
  stack_name         = "rand-pocs" # this must match the stack name the service deploys into
  name_prefix        = "${local.stack_name}-${var.environment}"
  global_prefix      = "global-${var.environment}"
  whole_service_name = "weblate"
  weblate_tag        = "${var.environment}-${local.whole_service_name}"

  stack_secrets_path   = "applications/${var.aws_profile}/${var.environment}/${local.stack_name}-stack"
  service_secrets_path = "${local.stack_secrets_path}/weblate"

  kms_alias = "alias/${var.aws_profile}/environment-services-kms"
  lb_name   = "alb-randd-rand"

  vpc_name                   = local.stack_secrets["vpc_name"]
  application_subnet_ids     = data.aws_subnets.application.ids
  application_subnet_pattern = local.stack_secrets["application_subnet_pattern"]

  db_name            = "${var.environment}-${local.whole_service_name}-postgresdb"
  db_master_username = local.service_secrets["psql_master_user"]
  db_master_password = local.service_secrets["psql_master_password"]

  # Secrets
  stack_secrets   = jsondecode(data.vault_generic_secret.stack_secrets.data_json)
  service_secrets = jsondecode(data.vault_generic_secret.service_secrets.data_json)

  # GLOBAL: create a map of secret name => secret arn to pass into ecs service module
  global_secrets_arn_map = {
    for sec in data.aws_ssm_parameter.global_secret :
    trimprefix(sec.name, "/${local.global_prefix}/") => sec.arn
  }

  # GLOBAL: create a list of secret name => secret arn to pass into ecs service module
  global_secret_list = flatten([for key, value in local.global_secrets_arn_map :
    { "name" = upper(key), "valueFrom" = value }
  ])

  # SERVICE: create a map of secret name => secret arn to pass into ecs service module
  service_secrets_arn_map = {
    for sec in module.secrets.secrets :
    trimprefix(sec.name, "/${local.whole_service_name}-${var.environment}/") => sec.arn
  }

  # SERVICE: create a list of secret name => secret arn to pass into ecs service module
  service_secret_list = flatten([for key, value in local.service_secrets_arn_map :
    { "name" = upper(key), "valueFrom" = value }
  ])

  # TASK SECRET: GLOBAL SECRET + SERVICE SECRET
  task_secrets = concat(local.global_secret_list, local.service_secret_list, [
  ])

  # GLOBAL: create a map of secret name and secret version to pass into ecs service module
  ssm_global_version_map = [
    for sec in data.aws_ssm_parameter.global_secret : {
      name = "GLOBAL_${var.ssm_version_prefix}${replace(upper(basename(sec.name)), "-", "_")}", value = sec.version
    }
  ]

  # SERVICE: create a map of secret name and secret version to pass into ecs service module
  ssm_service_version_map = [
    for sec in module.secrets.secrets : {
      name = "${replace(upper(local.whole_service_name), "-", "_")}_${var.ssm_version_prefix}${replace(upper(basename(sec.name)), "-", "_")}", value = sec.version
    }
  ]

  # TASK ENVIRONMENT: GLOBAL SECRET Version + SERVICE SECRET Version
  task_environment = concat(local.ssm_global_version_map, local.ssm_service_version_map, [
    { name : "DUMMY_VALUE", value : "23" },
    { name : "WEBLATE_DEBUG", value : "1" },
    { name : "URL_PREFIX", value : "/weblate" },
    { name : "WEBLATE_LOGLEVEL", value : "DEBUG" },
    { name : "POSTGRES_HOST", value : aws_db_instance.weblate.address },
    { name : "POSTGRES_DB", value : aws_db_instance.weblate.db_name },
    { name : "REDIS_HOST", value : aws_elasticache_replication_group.weblate.primary_endpoint_address }
  ])

  multi_ecs_volume_data_name  = "weblate-data"  # this is shared across all ECS services

  # ECS SETTINGS (COMMON)
  ecs_common = {
    use_set_environment_files = var.use_set_environment_files

    # Environmental configuration
    environment             = var.environment
    aws_region              = var.aws_region
    aws_profile             = var.aws_profile
    vpc_id                  = data.aws_vpc.vpc.id
    ecs_cluster_id          = data.aws_ecs_cluster.ecs_cluster.id
    task_execution_role_arn = data.aws_iam_role.ecs_cluster_iam_role.arn

    batch_service = true # default to true for all services (only web will override with false)
    # Load balancer configuration (empty apart from web)
    lb_listener_arn           = ""
    lb_listener_rule_priority = 1
    lb_listener_paths         = []

    # ECS Task container health check
    use_task_container_healthcheck    = true
    healthcheck_command               = "/app/bin/health_check"
    health_check_grace_period_seconds = 300
    healthcheck_healthy_threshold     = "2"

    # Docker container details
    docker_registry   = var.docker_registry
    docker_repo       = "weblate-image"
    container_version = var.weblate_image_version

    read_only_root_filesystem = false
    volumes =  [
        {
            "name": local.multi_ecs_volume_data_name,
            "efsVolumeConfiguration": {
                "fileSystemId": aws_efs_file_system.weblate.id,
                "rootDirectory": "/",
                "transitEncryption": "ENABLED"
            }
        }
    ]

    mount_points = [
      { "sourceVolume" : local.multi_ecs_volume_data_name,   "containerPath" : "/app/data", "readOnly" : false }
    ]

    # Service configuration
    name_prefix = local.name_prefix

    # Service performance and scaling configs
    service_autoscale_enabled  = var.service_autoscale_enabled
    service_scaledown_schedule = var.service_scaledown_schedule
    service_scaleup_schedule   = var.service_scaleup_schedule
    use_capacity_provider      = var.use_capacity_provider
    use_fargate                = var.use_fargate
    fargate_subnets            = local.application_subnet_ids

    # Cloudwatch
    cloudwatch_alarms_enabled = var.cloudwatch_alarms_enabled

    # Service environment variable and secret configs
    task_environment = local.task_environment
    task_secrets     = local.task_secrets

    task_role_arn          = aws_iam_role.ecs_task_role.arn
    enable_execute_command = true
  }

  # ECS SETTINGS (SERVICE-SPECIFIC)
  ecs_custom_vars = [
    #  !
    #  ! NOTE:
    #  ! these "service_name" strings are defined by Weblate:
    #  ! https://docs.weblate.org/en/latest/admin/install/docker.html#envvar-WEBLATE_SERVICE
    #  !
    {
      service_name   = "web"
      batch_service  = false
      container_port = 8080

      # Load balancer configuration
      lb_listener_arn           = data.aws_lb_listener.rand_lb_listener.arn
      lb_listener_rule_priority = 35
      lb_listener_paths         = ["/weblate", "/weblate/*"]

      healthcheck_path                  = "/healthz/"
      health_check_grace_period_seconds = 300
      healthcheck_healthy_threshold     = "2"
    },
    {
      service_name = "celery-celery"
    },
    {
      service_name = "celery-translate"
    },
    {
      service_name = "celery-notify"
    },
    {
      service_name = "celery-memory"
    },
    {
      service_name = "celery-backup"
    },
    {
      service_name = "celery-beat"
    }
  ]

  # Define a local that builds the config map for all services
  ecs_service_configs = {
    for c in local.ecs_custom_vars :
    c.service_name => merge(
      local.ecs_common,
      c,
      var.ecs_configs[c.service_name],
      {
        service_name             = "weblate-${c.service_name}"
        app_environment_filename = "weblate-${c.service_name}.env"
        task_environment = concat(
          local.ecs_common.task_environment,
          lookup(c, "task_environment", []), # service-specific (if any)
          [
            {
              name  = "WEBLATE_SERVICE"
              value = c.service_name
            }
          ]
        )
      }
    )
  }

  ecs_security_group_ids = flatten([
    # Collect from the first module loop (actually only 1: "weblate-celery-beat")
    [for m in module.ecs-services : m.security_group_id],

    # Collect from the second module loop (all the remaining services)
    [for m in module.ecs-service-celery-beat : m.security_group_id]
  ])

}


