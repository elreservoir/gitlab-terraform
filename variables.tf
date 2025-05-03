/*
 * Hashicorp Vault credentials
 */

variable "vault_token" {
  type = string
  sensitive = true
}

variable "vault_address" {
  type = string
  sensitive = true
}

/*
 * Load secrets from Hashicorp Vault
 */

data "vault_kv_secret_v2" "docker_secrets" {
  mount = "kv"
  name = "docker"
}

data "vault_kv_secret_v2" "github_secrets" {
  mount = "kv"
  name = "github"
}

data "vault_kv_secret_v2" "gitlab_secrets" {
  mount = "kv"
  name = "gitlab"
}

data "vault_kv_secret_v2" "renovate_secrets" {
  mount = "kv"
  name = "renovate"
}