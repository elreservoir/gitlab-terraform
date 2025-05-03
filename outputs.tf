/*
 * Store secrets to Hashicorp Vault
 */

resource "vault_kv_secret_v2" "add_secrets" {
  mount = "kv"
  name  = "gitlab/generated"

  delete_all_versions = true

  data_json = jsonencode(
    {
      GITLAB_RUNNER_TOKEN = gitlab_user_runner.instance-runner.token
      RENOVATE_BOT_TOKEN = gitlab_personal_access_token.renovate-bot.token
    }
  )
}