terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = ">=6.6.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">=17.11.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = ">=4.8.0"
    }
  }
}