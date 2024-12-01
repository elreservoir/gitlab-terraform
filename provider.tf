terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "homelab_iluckyw"
    workspaces {
      name = "default"
    }
  }

  required_providers {
    github = {
      source = "integrations/github"
      version = "6.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "17.4.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "4.4.0"
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
}