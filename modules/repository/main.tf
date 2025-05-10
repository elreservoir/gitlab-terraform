resource "gitlab_project" "gitlab_repository" {
  name = var.name
  namespace_id = var.namespace_id
  description = var.description
  avatar = var.avatar

  visibility_level= "private"

  wiki_enabled = false
  packages_enabled = false
  auto_devops_enabled = false

  lifecycle {
    ignore_changes = [ avatar_hash ]
  }
}

/*
 * GitHub project mirroring
 * Conditional on: "var.github_mirror_name"
 */

resource "null_resource" "sync_gitlab_and_github" {
  depends_on = [gitlab_project.gitlab_repository]
  count = var.github_mirror_name != "" ? 1 : 0

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/sync_gitlab_and_github.sh ${local.github_username} ${var.github_mirror_name} ${local.gitlab_clone_url} ${local.github_clone_url}"
    environment = {
      GITHUB_TOKEN = local.github_token
    }
  }

  triggers = {
    gitlab_repo_id = gitlab_project.gitlab_repository.id
  }
}

resource "gitlab_project_mirror" "repository-mirror" {
  depends_on = [null_resource.sync_gitlab_and_github]

  project = gitlab_project.gitlab_repository.id
  url = local.github_clone_url
  enabled = true

  lifecycle {
    ignore_changes = [
      only_protected_branches,
    ]
  }
}

/*
 * Resources for renovate
 * Conditional on: "var.renovate_bot_id"
 */

resource "gitlab_project_membership" "renovate" {
  count = var.renovate_bot_id != "" ? 1 : 0

  project = gitlab_project.gitlab_repository.id
  user_id = var.renovate_bot_id
  access_level = "developer"
}

resource "gitlab_project_hook" "renovatehook" {
  count = var.renovate_bot_id != "" ? 1 : 0

  project = gitlab_project.gitlab_repository.id
  url = local.renovate_webhook_url
  token = local.renovate_webhook_token
  push_events = false
  issues_events = true
  enable_ssl_verification = false
}

/*
 * Pipeline variables
 */
resource "gitlab_project_variable" "ci_variables" {
  for_each = {
    for v in var.ci_variables : v.key => v
  }

  project = gitlab_project.gitlab_repository.id
  key = each.value.key
  value = each.value.value
  protected = true
  masked = each.value.sensitive
  hidden = each.value.sensitive
}