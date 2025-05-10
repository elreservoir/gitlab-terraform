#!/usr/bin/env bash
set -euo pipefail

GITHUB_USER="$1"
GITHUB_REPO_NAME="$2"
GITLAB_CLONE_URL="$3"
GITHUB_CLONE_URL="$4"

# Check if GitHub repo exists
status=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token ${GITHUB_TOKEN}" \
  "https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO_NAME}")

if [ "$status" -eq 200 ]; then
  echo "GitHub repo exists, pulling and pushing to GitLab..."
  tmpdir=$(mktemp -d)
  git clone --mirror "$GITHUB_CLONE_URL" "$tmpdir"
  cd "$tmpdir"
  git remote set-url origin "$GITLAB_CLONE_URL"
  git push --mirror
else
  echo "GitHub repo does not exist, creating..."
  curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
    -d "{\"name\": \"${GITHUB_REPO_NAME}\"}" \
    https://api.github.com/user/repos

  echo "Pushing from GitLab to new GitHub repo..."
  tmpdir=$(mktemp -d)
  git clone --mirror "$GITLAB_CLONE_URL" "$tmpdir"
  cd "$tmpdir"
  git remote set-url origin "$GITHUB_CLONE_URL"
  git push --mirror
fi