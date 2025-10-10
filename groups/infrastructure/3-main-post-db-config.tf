// This triggers the 3rd phase (to deploy remaining resources, mainly ECS)
module "post_db_config" {
  source = "./module-post-db-config"
  config = {
    name_prefix            = local.name_prefix
    weblate_tag            = local.weblate_tag
    vpc_id                 = data.aws_vpc.vpc.id
    lb_name                = local.lb_name
    ecs_security_group_ids = local.ecs_security_group_ids
    application_subnet_ids = local.application_subnet_ids
  }
}
