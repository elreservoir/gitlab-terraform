#!/bin/bash
set -e

GITHUB_USER="$1"
GITHUB_REPO="$2"
GITHUB_TOKEN="${GITHUB_TOKEN}"

if curl -sf -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_USER/$REPO" >/dev/null; then
  echo "{\"exists\": true}"
else
  echo "{\"exists\": false}"
fi
