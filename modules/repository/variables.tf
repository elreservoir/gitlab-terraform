/*
 * module paramter
 */
variable "name" {}
variable "description" {}
variable "avatar" {}
variable "github_mirror_name" {
  default     = ""
}
variable "namespace_id" {}
variable "renovate_bot_id" {
  default     = ""
}

/*
 * loaded from hashicorp vault
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

locals {
    github_username = data.vault_kv_secret_v2.github_secrets.data["GITHUB_USERNAME"]
    github_token = data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]
    gitlab_username = data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]
    gitlab_token = data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]

    github_clone_url = var.github_mirror_name != "" ? "https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(github_repository.github_repository[0].http_clone_url, "https://")}" : null
    gitlab_clone_url = "https://${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]}:${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]}@${trimprefix(gitlab_project.gitlab_repository.http_url_to_repo, "https://")}"

    renovate_webhook_url = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_URL"]
    renovate_webhook_token = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_TOKEN"]
}

/*
 * check if github repo exists
 */
resource "null_resource" "check_github_repo" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/check_github_repo_exists.sh ${local.github_username} ${var.github_mirror_name} > ${path.module}/.github_status.json"
    environment = {
      GITHUB_TOKEN = local.github_token
    }
  }

  triggers = {
    repo_name = var.github_mirror_name
  }
}

data "external" "github_status" {
  program = ["cat", "${path.module}/.github_status.json"]
  depends_on = [null_resource.check_github_repo]
}