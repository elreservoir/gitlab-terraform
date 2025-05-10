/*
 * module paramter
 */

variable "name" {}
variable "description" {}
variable "avatar" {}
variable "github_mirror_name" {
  default = ""
}
variable "namespace_id" {}
variable "renovate_bot_id" {
  default = ""
}
variable "ci_variables" {
  type = list(object({
    key = string
    value = string
    sensitive = optional(bool, false)
  }))
  default = []
}

/*
 * load from hashicorp vault
 */

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

/*
 * put needed vars together
 */

locals {
    github_username = data.vault_kv_secret_v2.github_secrets.data["GITHUB_USERNAME"]
    github_token = data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]
    gitlab_username = data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]
    gitlab_token = data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]

    gitlab_clone_url = "https://${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]}:${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]}@${trimprefix(gitlab_project.gitlab_repository.http_url_to_repo, "https://")}"
    github_clone_url = var.github_mirror_name != "" ? "https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@github.com/${local.github_username}/${var.github_mirror_name}.git" : null

    renovate_webhook_url = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_URL"]
    renovate_webhook_token = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_TOKEN"]
}