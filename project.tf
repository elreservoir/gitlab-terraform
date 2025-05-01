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
  avatar = "${path.module}/ressources/docker.png"

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
 * GitLab Project
 */

resource "gitlab_project" "gitlab" {
  name = "GitLab Terraform"
  namespace_id = gitlab_group.homelab.id
  description = "GitLab Terraform project"
  avatar = "${path.module}/ressources/terraform-gitlab.png"

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

  lifecycle {
    ignore_changes = [
      only_protected_branches,
    ]
  }
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
 * AdGuard Project
 */

resource "gitlab_project" "adguard" {
  name = "AdGuard Terraform"
  namespace_id = gitlab_group.homelab.id
  description = "AdGuard Terraform project"
  avatar = "${path.module}/ressources/terraform-adguard.png"

  visibility_level= "private"

  wiki_enabled = false
  packages_enabled = false
  auto_devops_enabled = false

  lifecycle {
    ignore_changes = [ avatar_hash ]
  }
}

data "github_repository" "github-adguard" {
  name = "adguard-terraform"
}

resource "null_resource" "import-adguard" {
  triggers = {
    gitlab_project_id = gitlab_project.adguard.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      git clone https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(data.github_repository.github-adguard.http_clone_url, "https://")} adguard_repo
      cd adguard_repo
      git remote add gitlab https://${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]}:${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]}@${trimprefix(gitlab_project.adguard.http_url_to_repo, "https://")}
      git push -u gitlab --all
      rm -rf ../adguard_repo
    EOT
  }
}

resource "gitlab_project_mirror" "adguard-mirror" {
  project = gitlab_project.adguard.id
  url = "https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_USERNAME"]}:${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(data.github_repository.github-adguard.http_clone_url, "https://")}"
  enabled = true

  lifecycle {
    ignore_changes = [
      only_protected_branches,
    ]
  }
}

resource "gitlab_project_membership" "adguard-renovate" {
  project = gitlab_project.adguard.id
  user_id = gitlab_user.renovate-bot.id
  access_level = "developer"
}

resource "gitlab_project_hook" "adguard-renovatehook" {
  project = gitlab_project.adguard.id
  url = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_URL"]
  token = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_TOKEN"]
  push_events = false
  issues_events = true
  enable_ssl_verification = false

  depends_on = [ gitlab_application_settings.gitlab_application_settings ]
}

/*
 * Oracle Cloud Project
 */

resource "gitlab_project" "oracle-cloud" {
  name = "Oracle Cloud Terraform"
  namespace_id = gitlab_group.homelab.id
  description = "Oracle Cloud Terraform project"
  avatar = "${path.module}/ressources/terraform-oracle-cloud.png"

  visibility_level= "private"

  wiki_enabled = false
  packages_enabled = false
  auto_devops_enabled = false

  lifecycle {
    ignore_changes = [ avatar_hash ]
  }
}

data "github_repository" "github-oracle_cloud" {
  name = "oracle_cloud-terraform"
}

resource "github_repository" "github_oracle-cloud" {
  name        = "oracle-cloud-terraform"
  visibility  = "private"
  auto_init   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "null_resource" "import_oracle-cloud" {
  triggers = {
    gitlab_project_id = gitlab_project.oracle-cloud.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      git clone https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(github_repository.github_oracle-cloud.http_clone_url, "https://")} oracle-cloud_repo
      cd oracle-cloud_repo
      git remote add gitlab https://${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]}:${data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]}@${trimprefix(gitlab_project.oracle-cloud.http_url_to_repo, "https://")}
      git push -u gitlab --all
      rm -rf ../oracle-cloud_repo
    EOT
  }
}

resource "gitlab_project_mirror" "oracle-cloud_mirror" {
  project = gitlab_project.oracle-cloud.id
  url = "https://${data.vault_kv_secret_v2.github_secrets.data["GITHUB_USERNAME"]}:${data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]}@${trimprefix(github_repository.github_oracle-cloud.http_clone_url, "https://")}"
  enabled = true

  lifecycle {
    ignore_changes = [
      only_protected_branches,
    ]
  }
}

resource "gitlab_project_membership" "oracle-cloud_renovate" {
  project = gitlab_project.oracle-cloud.id
  user_id = gitlab_user.renovate-bot.id
  access_level = "developer"
}

resource "gitlab_project_hook" "oracle-cloud_renovatehook" {
  project = gitlab_project.oracle-cloud.id
  url = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_URL"]
  token = data.vault_kv_secret_v2.renovate_secrets.data["RENOVATE_WEBHOOK_TOKEN"]
  push_events = false
  issues_events = true
  enable_ssl_verification = false

  depends_on = [ gitlab_application_settings.gitlab_application_settings ]
}

/*
 * Ansible Project
 */

resource "gitlab_project" "ansible" {
  name = "Ansible"
  namespace_id = gitlab_group.homelab.id
  description = "Ansible project"
  avatar = "${path.module}/ressources/ansible.png"

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

  lifecycle {
    ignore_changes = [
      only_protected_branches,
    ]
  }
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