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
  avatar = "${path.module}/assets/docker.png"

  visibility_level= "private"

  wiki_enabled = false
  packages_enabled = false
  auto_devops_enabled = false

  depends_on = [ gitlab_application_settings.gitlab_application_settings ]

  lifecycle {
    ignore_changes = [ avatar_hash ]
  }
}

data "github_repository" "github-swarm" {
  name = "docker-swarm"
}

resource "null_resource" "import-swarm" {
  triggers = {
    gitlab_project_id = gitlab_project.swarm.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      git clone https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(data.github_repository.github-swarm.http_clone_url, "https://")} swarm_repo
      cd swarm_repo
      git remote add gitlab https://${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]}:${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]}@${trimprefix(gitlab_project.swarm.http_url_to_repo, "https://")}
      git push -u gitlab --all
      rm -rf ../swarm_repo
    EOT
  }
}

resource "gitlab_project_mirror" "swarm-mirror" {
  project = gitlab_project.swarm.id
  url = "https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_USERNAME"]}:${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(data.github_repository.github-swarm.http_clone_url, "https://")}"
  enabled = true
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

/*
 * GitLab Project
 */

resource "gitlab_project" "gitlab" {
  name = "GitLab Terraform"
  namespace_id = gitlab_group.homelab.id
  description = "GitLab Terraform project"
  avatar = "${path.module}/assets/gitlab.png"

  visibility_level= "private"

  wiki_enabled = false
  packages_enabled = false
  auto_devops_enabled = false

  lifecycle {
    ignore_changes = [ avatar_hash ]
  }
}

data "github_repository" "github-gitlab" {
  name = "gitlab-terraform"
}

resource "null_resource" "import-gitlab" {
  triggers = {
    gitlab_project_id = gitlab_project.gitlab.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      git clone https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(data.github_repository.github-gitlab.http_clone_url, "https://")} gitlab_repo
      cd gitlab_repo
      git remote add gitlab https://${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]}:${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]}@${trimprefix(gitlab_project.gitlab.http_url_to_repo, "https://")}
      git push -u gitlab --all
      rm -rf ../gitlab_repo
    EOT
  }
}

resource "gitlab_project_mirror" "gitlab-mirror" {
  project = gitlab_project.gitlab.id
  url = "https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_USERNAME"]}:${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(data.github_repository.github-gitlab.http_clone_url, "https://")}"
  enabled = true
}

resource "gitlab_project_membership" "gitlab-renovate" {
  project = gitlab_project.gitlab.id
  user_id = gitlab_user.renovate-bot.id
  access_level = "developer"
}

resource "gitlab_project_hook" "gitlab-renovatehook" {
  project = gitlab_project.gitlab.id
  url = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_URL"]
  token = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_TOKEN"]
  push_events = false
  issues_events = true
  enable_ssl_verification = false

  depends_on = [ gitlab_application_settings.gitlab_application_settings ]
}

/*
 * Ansivle Project
 */

resource "gitlab_project" "ansible" {
  name = "Ansible"
  namespace_id = gitlab_group.homelab.id
  description = "Ansible project"
  avatar = "${path.module}/assets/ansible.png"

  visibility_level= "private"

  wiki_enabled = false
  packages_enabled = false
  auto_devops_enabled = false

  lifecycle {
    ignore_changes = [ avatar_hash ]
  }
}

data "github_repository" "github-ansible" {
  name = "ansible"
}

resource "null_resource" "import-ansible" {
  triggers = {
    gitlab_project_id = gitlab_project.ansible.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      git clone https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(data.github_repository.github-ansible.http_clone_url, "https://")} ansible_repo
      cd ansible_repo
      git remote add gitlab https://${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]}:${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]}@${trimprefix(gitlab_project.ansible.http_url_to_repo, "https://")}
      git push -u gitlab --all
      rm -rf ../ansible_repo
    EOT
  }
}

resource "gitlab_project_mirror" "ansible-mirror" {
  project = gitlab_project.ansible.id
  url = "https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_USERNAME"]}:${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(data.github_repository.github-ansible.http_clone_url, "https://")}"
  enabled = true
}

resource "gitlab_project_membership" "ansible-renovate" {
  project = gitlab_project.ansible.id
  user_id = gitlab_user.renovate-bot.id
  access_level = "developer"
}

resource "gitlab_project_hook" "ansible-renovatehook" {
  project = gitlab_project.ansible.id
  url = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_URL"]
  token = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_TOKEN"]
  push_events = false
  issues_events = true
  enable_ssl_verification = false

  depends_on = [ gitlab_application_settings.gitlab_application_settings ]
}

/*
 * Testing Project
 */
resource "gitlab_project" "docker_compose_deploy" {
  name        = "docker-compose-deploy"
  description = "Automates deployment of Docker Compose files."
  visibility_level = "private"
}

resource "gitlab_repository_file" "gitlab-ci" {
  project = gitlab_project.docker_compose_deploy.id
  file_path = ".gitlab-ci.yml"
  branch = "main"
  content = base64encode(file("${path.module}/assets/.gitlab-ci.yml"))
  commit_message = "default gitlab-ci file"
}

resource "gitlab_project_variable" "docker_host" {
  project   = gitlab_project.docker_compose_deploy.id
  key       = "DOCKER_HOST"
  value     = data.vault_kv_secret_v2.docker_secrets.data["DOCKER_HOST"]
}

resource "gitlab_project_variable" "vault_token" {
  project   = gitlab_project.docker_compose_deploy.id
  key       = "VAULT_TOKEN"
  value     = var.vault_token
}

resource "gitlab_project_variable" "vault_url" {
  project   = gitlab_project.docker_compose_deploy.id
  key       = "VAULT_URL"
  value     = var.vault_address
}