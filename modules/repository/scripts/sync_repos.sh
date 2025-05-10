#!/bin/bash
set -e

REPO_NAME="$1"
GITLAB_CLONE_URL="$2"
GITHUB_CLONE_URL="$3"
REPO_EXISTED="$4"

WORKDIR=$(mktemp -d)

echo "📦 Sync starte für $REPO_NAME"
echo "GitHub Repo existiert: $EXISTS"

if [ "$REPO_EXISTED" == "false" ]; then
  echo "🚀 GitHub Repo noch nicht vorhanden – pushe GitLab → GitHub"
  git clone --mirror "$GITLAB_CLONE_URL" "$WORKDIR/repo"
  cd "$WORKDIR/repo"
  git remote add github "$GITHUB_CLONE_URL"
  git push --mirror github
else
  echo "🔄 GitHub Repo vorhanden – pushe GitHub → GitLab"
  git clone --mirror "$GITHUB_CLONE_URL" "$WORKDIR/repo"
  cd "$WORKDIR/repo"
  git remote add gitlab "$GITLAB_CLONE_URL"
  git push --mirror gitlab
fi

cd /
rm -rf "$WORKDIR"