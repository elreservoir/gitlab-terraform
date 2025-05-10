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

resource "github_repository" "github_repository" {
  count = var.github_mirror_name != "" ? 1 : 0

  name        = var.github_mirror_name
  visibility  = "private"
  auto_init   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "gitlab_project_mirror" "repository-mirror" {
  count = var.github_mirror_name != "" ? 1 : 0

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
 * Script to either restore data from github or initially push to github
 */
resource "null_resource" "sync_git_repos" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/sync_repos.sh ${var.github_mirror_name} ${local.gitlab_clone_url} ${local.github_clone_url} ${path.module}/.github_status.json"
    environment = {
      GITHUB_TOKEN = local.github_token
      GITLAB_TOKEN = local.gitlab_token
    }
  }

  triggers = {
    github_repo_id = github_repository.github_repository[0].node_id
  }

  depends_on = [
    gitlab_project.gitlab_repository,
    github_repository.github_repository,
    data.external.github_status
  ]
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