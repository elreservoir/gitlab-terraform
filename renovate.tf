resource "gitlab_user" "renovate-bot" {
  name = "Renovate Bot"
  username = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_BOT_USERNAME"]
  password = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_BOT_PASSWORD"]
  email = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_BOT_EMAIL"]
}

 resource "gitlab_personal_access_token" "renovate-bot" {
  user_id = gitlab_user.renovate-bot.id
  name = "personal access token for renovate bot"
  scopes = ["api", "read_user", "write_repository"]
}

resource "gitlab_system_hook" "renovate-system-hook" {
  url = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_URL"]
  token = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_TOKEN"]
  repository_update_events = false
  push_events = true
  merge_requests_events = true
  tag_push_events = false
  enable_ssl_verification = false

  depends_on = [ gitlab_application_settings.gitlab_application_settings ]

  lifecycle {
    ignore_changes = [ id ]
  }
}