locals {
  # Secrets
  stack_secrets   = jsondecode(data.vault_generic_secret.stack_secrets.data_json)
  service_secrets = jsondecode(data.vault_generic_secret.service_secrets.data_json)

  service_secrets_sanitised = {
    for k, v in local.service_secrets :
    k => v if !contains([
      "psql_master_user",
      "psql_master_password",
    ], k)
  }
}
