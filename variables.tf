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

data "vault_kv_secret_v2" "semaphore_secrets" {
  mount = "kv"
  name = "semaphore"
}

/*
 * Store secrets to Hashicorp Vault
 */

resource "vault_kv_secret_v2" "add_secrets" {
  mount = "kv"
  name  = "generated"

  delete_all_versions = true

  data_json = jsonencode(
    {
      GITLAB_RUNNER_TOKEN = gitlab_user_runner.instance-runner.token
      RENOVATE_BOT_TOKEN = gitlab_personal_access_token.renovate-bot.token
    }
  )
}