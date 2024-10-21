data "gitlab_user" "root" {
    username = data.vault_kv_secret_v2.gitlab_secrets.data["GITLAB_USERNAME"]
}

resource "gitlab_user_sshkey" "semaphore_ssh" {
  user_id = data.gitlab_user.root.id
  title = "gitlab"
  key = data.vault_kv_secret_v2.gitlab_secrets.data["SSH_PUBLIC_KEY"]
}