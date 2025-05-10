resource "gitlab_application_settings" "gitlab_application_settings" {
  allow_local_requests_from_web_hooks_and_services = true
  import_sources = [ "github" ]
}

resource "gitlab_user_runner" "instance-runner" {
  runner_type = "instance_type"
}

/*
 * Docker Swarm Project
 */

resource "gitlab_project" "swarm" {
  name = "Docker Swarm"
  namespace_id = gitlab_group.homelab.id
  description = "Docker Swarm Compose Files"
  avatar = "${path.module}/resources/docker.png"

  visibility_level= "private"

  wiki_enabled = false
  packages_enabled = false
  auto_devops_enabled = false

  ci_forward_deployment_enabled = false
  auto_cancel_pending_pipelines = "disabled"

  depends_on = [ gitlab_application_settings.gitlab_application_settings ]

  lifecycle {
    ignore_changes = [ avatar_hash ]
  }
}

resource "github_repository" "github_swarm" {
  name        = "docker-swarm"
  visibility  = "private"
  auto_init   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "null_resource" "import-swarm" {
  triggers = {
    gitlab_project_id = gitlab_project.swarm.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      git clone https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(github_repository.github_swarm.http_clone_url, "https://")} swarm_repo
      cd swarm_repo
      git remote add gitlab https://${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]}:${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]}@${trimprefix(gitlab_project.swarm.http_url_to_repo, "https://")}
      git push -u gitlab --all
      rm -rf ../swarm_repo
    EOT
  }
}

resource "gitlab_project_mirror" "swarm-mirror" {
  project = gitlab_project.swarm.id
  url = "https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_USERNAME"]}:${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(github_repository.github_swarm.http_clone_url, "https://")}"
  enabled = true

  lifecycle {
    ignore_changes = [
      only_protected_branches,
    ]
  }
}

resource "gitlab_project_membership" "swarm-renovate" {
  project = gitlab_project.swarm.id
  user_id = gitlab_user.renovate-bot.id
  access_level = "developer"
}

resource "gitlab_project_hook" "swarm-renovatehook" {
  project = gitlab_project.swarm.id
  url = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_URL"]
  token = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_TOKEN"]
  push_events = false
  issues_events = true
  enable_ssl_verification = false

  depends_on = [ gitlab_application_settings.gitlab_application_settings ]
}

// Pipeline Settings

resource "gitlab_project_variable" "docker_host" {
  project   = gitlab_project.swarm.id
  key       = "DOCKER_HOST"
  value     = data.vault_kv_secret_v2.docker_secrets.data["DOCKER_HOST"]
  protected = true
}

resource "gitlab_project_variable" "portainer_endpoint_id" {
  project   = gitlab_project.swarm.id
  key       = "PORTAINER_ENDPOINT_ID"
  value     = data.vault_kv_secret_v2.docker_secrets.data["PORTAINER_ENDPOINT_ID"]
  protected = true
}

resource "gitlab_project_variable" "portainer_swarm_id" {
  project   = gitlab_project.swarm.id
  key       = "PORTAINER_SWARM_ID"
  value     = data.vault_kv_secret_v2.docker_secrets.data["PORTAINER_SWARM_ID"]
  protected = true
}

resource "gitlab_project_variable" "portainer_addr" {
  project   = gitlab_project.swarm.id
  key       = "PORTAINER_ADDR"
  value     = data.vault_kv_secret_v2.docker_secrets.data["PORTAINER_ADDR"]
  protected = true
}

resource "gitlab_project_variable" "portainer_token" {
  project   = gitlab_project.swarm.id
  key       = "PORTAINER_TOKEN"
  value     = data.vault_kv_secret_v2.docker_secrets.data["PORTAINER_TOKEN"]
  masked    = true
  hidden    = true
  protected = true
}

/*
 * Repositories
 */

module "gitlab_repository" {
  source = "./modules/repository"

  name = "GitLab Terraform"
  description = "GitLab Terraform project"
  avatar = "${path.module}/resources/gitlab-terraform.png"

  github_mirror_name = "gitlab-terraform"

  namespace_id = gitlab_group.homelab.id
  renovate_bot_id = gitlab_user.renovate-bot.id
}

module "adguard_repository" {
  source = "./modules/repository"

  name = "AdGuard Terraform"
  description = "AdGuard Terraform project"
  avatar = "${path.module}/resources/adguard-terraform.png"

  github_mirror_name = "adguard-terraform"

  namespace_id = gitlab_group.homelab.id
  renovate_bot_id = gitlab_user.renovate-bot.id
}

module "oracle_cloud_repository" {
  source = "./modules/repository"

  name = "Oracle Cloud Terraform"
  description = "Oracle Cloud Terraform project"
  avatar = "${path.module}/resources/oracle-cloud-terraform.png"

  github_mirror_name = "oracle-cloud-terraform"

  namespace_id = gitlab_group.homelab.id
  renovate_bot_id = gitlab_user.renovate-bot.id
}

module "packer_repository" {
  source = "./modules/repository"

  name = "Packer"
  description = "Packer project"
  avatar = "${path.module}/resources/packer.png"

  github_mirror_name = "packer"

  namespace_id = gitlab_group.homelab.id
  renovate_bot_id = gitlab_user.renovate-bot.id
}

module "ansible_repository" {
  source = "./modules/repository"

  name = "Ansible"
  description = "Ansible project"
  avatar = "${path.module}/resources/ansible.png"

  github_mirror_name = "ansible"

  namespace_id = gitlab_group.homelab.id
  renovate_bot_id = gitlab_user.renovate-bot.id
}

module "gitlab_ci_repository" {
  source = "./modules/repository"

  name = "GitLab CI"
  description = "GitLab CI project"
  avatar = "${path.module}/resources/gitlab-ci.png"

  github_mirror_name = "gitlab-ci"

  namespace_id = gitlab_group.homelab.id
  renovate_bot_id = gitlab_user.renovate-bot.id
}