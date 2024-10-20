data "gitlab_user" "root" {
    username = "root"
}

resource "gitlab_user_sshkey" "semaphore_ssh" {
  user_id = data.gitlab_user.root.id
  title = "semaphore"
  key = data.vault_kv_secret_v2.semaphore_secrets.data["SSH_PUBLIC_KEY"]
}