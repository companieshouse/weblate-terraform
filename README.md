# Weblate on AWS (Terraform)

This terraform code deploys Weblate on AWS. Mainly the following Weblate components:
 - the required RDS/Postgres DB
 - the required Elasticache/Redis
 - Web server(s)  (as ECS service(s))
 - Celery workers (as ECS services)

See [Weblate architecture](https://docs.weblate.org/en/latest/admin/install.html#architecture-overview).
