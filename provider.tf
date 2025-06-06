terraform {
  #backend "http" {
    # The address will be provided by GitLab CI
  #}

  required_providers {
    github = {
      source = "integrations/github"
      version = "6.6.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "17.11.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "4.8.0"
    }
  }
}

provider "github" {
  token = data.vault_kv_secret_v2.github_secrets.data["GITHUB_TOKEN"]
}

provider "gitlab" {
  token = data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_TOKEN"]
  base_url = data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_BASE_URL"]
}

provider "vault" {
  address = var.vault_address
  token = var.vault_token
  skip_tls_verify = true
}