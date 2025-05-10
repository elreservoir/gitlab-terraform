resource "gitlab_application_settings" "gitlab_application_settings" {
  allow_local_requests_from_web_hooks_and_services = true
  import_sources = [ "github" ]
}

resource "gitlab_user_runner" "instance-runner" {
  runner_type = "instance_type"
}

/*
 * Repositories
 */

module "docker_swarm_repository" {
  source = "./modules/repository"

  name = "Docker Swarm"
  description = "Docker Swarm project"
  avatar = "${path.module}/resources/docker.png"

  namespace_id = gitlab_group.homelab.id
  github_mirror_name = "docker-swarm"
  renovate_bot_id = gitlab_user.renovate-bot.id

  ci_variables = [
    {
      key = "DOCKER_HOST"
      value = data.vault_kv_secret_v2.docker_secrets.data["DOCKER_HOST"]
    },
    {
      key = "PORTAINER_ENDPOINT_ID"
      value = data.vault_kv_secret_v2.docker_secrets.data["PORTAINER_ENDPOINT_ID"]
    },
    {
      key = "PORTAINER_SWARM_ID"
      value = data.vault_kv_secret_v2.docker_secrets.data["PORTAINER_SWARM_ID"]
    },
    {
      key = "PORTAINER_ADDR"
      value = data.vault_kv_secret_v2.docker_secrets.data["PORTAINER_ADDR"]
    },
    {
      key = "PORTAINER_TOKEN"
      value = data.vault_kv_secret_v2.docker_secrets.data["PORTAINER_TOKEN"]
      sensitive = true
    }
  ]
}

module "gitlab_repository" {
  source = "./modules/repository"

  name = "GitLab Terraform"
  description = "GitLab Terraform project"
  avatar = "${path.module}/resources/gitlab-terraform.png"

  namespace_id = gitlab_group.homelab.id
  github_mirror_name = "gitlab-terraform"
  renovate_bot_id = gitlab_user.renovate-bot.id
}

module "adguard_repository" {
  source = "./modules/repository"

  name = "AdGuard Terraform"
  description = "AdGuard Terraform project"
  avatar = "${path.module}/resources/adguard-terraform.png"

  namespace_id = gitlab_group.homelab.id
  github_mirror_name = "adguard-terraform"
  renovate_bot_id = gitlab_user.renovate-bot.id
}

module "oracle_cloud_repository" {
  source = "./modules/repository"

  name = "Oracle Cloud Terraform"
  description = "Oracle Cloud Terraform project"
  avatar = "${path.module}/resources/oracle-cloud-terraform.png"

  namespace_id = gitlab_group.homelab.id
  github_mirror_name = "oracle-cloud-terraform"
  renovate_bot_id = gitlab_user.renovate-bot.id
}

module "packer_repository" {
  source = "./modules/repository"

  name = "Packer"
  description = "Packer project"
  avatar = "${path.module}/resources/packer.png"

  namespace_id = gitlab_group.homelab.id
  github_mirror_name = "packer"
  renovate_bot_id = gitlab_user.renovate-bot.id
}

module "ansible_repository" {
  source = "./modules/repository"

  name = "Ansible"
  description = "Ansible project"
  avatar = "${path.module}/resources/ansible.png"

  namespace_id = gitlab_group.homelab.id
  github_mirror_name = "ansible"
  renovate_bot_id = gitlab_user.renovate-bot.id
}

module "gitlab_ci_repository" {
  source = "./modules/repository"

  name = "GitLab CI"
  description = "GitLab CI project"
  avatar = "${path.module}/resources/gitlab-ci.png"

  namespace_id = gitlab_group.homelab.id
  github_mirror_name = "gitlab-ci"
  renovate_bot_id = gitlab_user.renovate-bot.id
}