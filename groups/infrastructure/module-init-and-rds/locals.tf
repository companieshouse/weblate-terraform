locals {
  ch_development_concourse_cidrs = values(data.vault_generic_secret.ch_development_concourse_cidrs.data)
}
