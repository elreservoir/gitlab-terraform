resource "gitlab_group" "homelab" {
  name = "Homelab"
  path = "homelab"
  description = "Everything associated to the homelab"
  avatar = "${path.module}/assets/home.png"

  lifecycle {
    ignore_changes = [ avatar_hash ]
  }
}

resource "gitlab_group_label" "renovate" {
  group = gitlab_group.homelab.id
  name = "renovate"
  description = "used for dependecy dashboard"
  color = "#D3D3D3"
}

resource "gitlab_group_label" "update" {
  group = gitlab_group.homelab.id
  name = "update"
  description = "update dependecy by renovate"
  color = "#0000FF"
}

resource "gitlab_group_label" "bug" {
  group = gitlab_group.homelab.id
  name = "bug"
  description = "bug that needs to be fixed"
  color = "#FF0000"
}

resource "gitlab_group_label" "enhancement" {
  group = gitlab_group.homelab.id
  name = "enhancement"
  description = "enhancement"
  color = "#008080"
}

resource "gitlab_group_label" "evaluation" {
  group = gitlab_group.homelab.id
  name = "evaluation"
  description = "evaluation"
  color = "#800080"
}

resource "gitlab_group_label" "note" {
  group = gitlab_group.homelab.id
  name = "note"
  description = "note"
  color = "#008000"
}

resource "gitlab_group_label" "migration" {
  group = gitlab_group.homelab.id
  name = "migration"
  description = "migration"
  color = "#FFa500"
}